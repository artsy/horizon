# frozen_string_literal: true

require "rails_helper"

RSpec::Matchers.define :a_tmp_dir do
  match do |actual|
    actual =~ /.*releasecop.*/ # pattern used by ReleasecopService
  end
end

RSpec.describe ReleasecopService, type: :service do
  include ActiveSupport::Testing::TimeHelpers
  let(:org) { Organization.create! name: "Artsy" }
  let(:project) do
    org.projects.create!(name: "shipping").tap do |p|
      p.stages.create!(name: "main")
      p.stages.create!(name: "production")
    end
  end

  describe "working dir not set by user" do
    it "uses a temp dir" do
      obj = ReleasecopService.new(project)
      expect(obj).to receive(:perform_comparison_in_dir).with(a_tmp_dir)
      obj.perform_comparison
    end
  end

  describe "working dir set by user" do
    it "uses user-specified dir" do
      Dir.mktmpdir(["user_specified_dir"]) do |dir| # using mktmpdir b/c it cleans up after
        allow(Horizon)
          .to receive(:config)
          .and_return({working_dir: dir})
        obj = ReleasecopService.new(project)
        expect(obj).to receive(:perform_comparison_in_dir).with(dir)
        obj.perform_comparison
      end
    end
  end

  describe "git sync and comparison" do
    let(:root) { Dir.mktmpdir("releasecop-spec") }
    let(:origin) { File.join(root, "origin") }
    let(:url) { "file://#{origin}" }
    let(:work) { File.join(root, "work").tap { |d| FileUtils.mkdir_p(d) } }
    let(:items) do
      [
        {"name" => "main", "git" => url, "branch" => "main"},
        {"name" => "production", "git" => url, "branch" => "release"}
      ]
    end

    def sh(*cmd, dir: origin)
      out, status = Open3.capture2e(*cmd, chdir: dir)
      raise out unless status.success?
      out
    end

    def commit(msg)
      sh("git", "-c", "user.name=a", "-c", "user.email=a@b.c", "commit", "--quiet", "--allow-empty", "-m", msg)
    end

    before do
      FileUtils.mkdir_p(origin)
      sh("git", "init", "--quiet", "--initial-branch=main")
      commit("shipped")
      sh("git", "branch", "release")
      commit("unreleased")
    end

    after { FileUtils.rm_rf(root) }

    it "fetches each remote once and compares the stage branches" do
      # and_call_original drops keyword args on this rspec-mocks version, so record calls by hand
      recorder = Module.new do
        def git!(*args, **kwargs)
          (Thread.current[:git_calls] ||= []) << args.first
          super
        end
      end
      ReleasecopService.singleton_class.prepend(recorder)
      Thread.current[:git_calls] = []
      ReleasecopService.sync_repo(work, "shipping", items)
      result = ReleasecopService::Checker.new("shipping", items, work).check
      expect(Thread.current[:git_calls].count("fetch")).to eq(1)
      expect(result.comparisons.map(&:lines).flatten.join).to include("unreleased")
      expect(result.comparisons.map(&:lines).flatten.join).not_to include("shipped")
    end

    it "picks up new commits on later runs" do
      ReleasecopService.sync_repo(work, "shipping", items)
      commit("newer")
      ReleasecopService.sync_repo(work, "shipping", items)
      lines = ReleasecopService::Checker.new("shipping", items, work).check.comparisons.first.lines
      expect(lines.join).to include("newer")
    end

    it "fetches a deployed SHA that isn't on a fetched branch" do
      sh("git", "checkout", "--quiet", "-b", "feature", "release")
      commit("deployed-from-feature")
      sha = sh("git", "rev-parse", "HEAD").strip
      sh("git", "checkout", "--quiet", "main")
      ReleasecopService.sync_repo(work, "shipping", items)
      allow_any_instance_of(Releasecop::ManifestItem).to receive(:for_rev_range) { |env| (env.name == "production") ? sha : "main/main" }
      lines = ReleasecopService::Checker.new("shipping", items, work).check.comparisons.first.lines
      expect(lines.join).to include("unreleased")
    end

    it "still compares when a deployed SHA can't be fetched" do
      ReleasecopService.sync_repo(work, "shipping", items)
      allow_any_instance_of(Releasecop::ManifestItem).to receive(:for_rev_range).and_return("f" * 40)
      expect { ReleasecopService::Checker.new("shipping", items, work).check }.not_to raise_error
    end

    it "keeps fetching when a tag is moved on the remote" do
      tagged = items.map { |i| i.merge("tag_pattern" => "^v") }
      sh("git", "tag", "v1", "release")
      ReleasecopService.sync_repo(work, "shipping", tagged)
      sh("git", "tag", "-f", "v1", "main")
      expect { ReleasecopService.sync_repo(work, "shipping", tagged) }.not_to raise_error
    end

    it "fetch_all returns per-project errors without raising" do
      bad = org.projects.create!(name: "broken").tap { |p| p.stages.create!(name: "main", git_remote: "file://#{root}/missing") }
      good = org.projects.create!(name: "fine").tap { |p| p.stages.create!(name: "main", git_remote: url, branch: "main") }
      results = ReleasecopService.fetch_all([bad, good], work)
      expect(results[good.id]).to be_nil
      expect(results[bad.id]).to be_a(ReleasecopService::GitError)
    end

    it "doesn't fetch the default branch for stages that compare a tag or hokusai SHA" do
      stages = [{"name" => "main", "git" => url, "branch" => "main"}, {"name" => "production", "git" => url, "tag_pattern" => "v*"}]
      sh("git", "tag", "v1", "release")
      # default branch "master" doesn't exist on the remote
      expect { ReleasecopService.sync_repo(work, "shipping", stages) }.not_to raise_error
    end

    it "doesn't fetch a hokusai stage's branch, which may not exist" do
      stages = [{"name" => "main", "git" => url, "branch" => "main"}, {"name" => "staging", "git" => url, "branch" => "staging", "hokusai" => "staging"}]
      expect { ReleasecopService.sync_repo(work, "shipping", stages) }.not_to raise_error
      sha = sh("git", "rev-parse", "release").strip
      allow_any_instance_of(Releasecop::ManifestItem).to receive(:find_hokusai_sha).and_return(sha)
      lines = ReleasecopService::Checker.new("shipping", stages, work).check.comparisons.first.lines
      expect(lines.join).to include("unreleased")
    end

    it "fails loudly when a hokusai stage with no branch finds no image SHA" do
      stages = [{"name" => "main", "git" => url, "branch" => "main"}, {"name" => "production", "git" => url, "hokusai" => "production"}]
      ReleasecopService.sync_repo(work, "shipping", stages)
      sh("git", "update-ref", "refs/remotes/production/master", "main", dir: File.join(work, "shipping")) # stale ref, as in an old clone
      allow_any_instance_of(Releasecop::ManifestItem).to receive(:find_hokusai_sha).and_return(nil)
      expect { ReleasecopService::Checker.new("shipping", stages, work).check }
        .to raise_error(ReleasecopService::GitError, /no deployed SHA/)
    end

    it "fetch_all keeps going when a project's stages can't be built" do
      profile = org.profiles.create!(name: "no-aws", environment: {"FOO" => "x"})
      bad = org.projects.create!(name: "broken").tap { |p| p.stages.create!(name: "main", git_remote: url, profile: profile) }
      good = org.projects.create!(name: "fine").tap { |p| p.stages.create!(name: "main", git_remote: url, branch: "main") }
      results = ReleasecopService.fetch_all([bad, good], work)
      expect(results[good.id]).to be_nil
      expect(results[bad.id]).to be_a(KeyError)
    end
  end

  describe ReleasecopService::ResultWrapper do
    it "keeps credentials out of the stored error" do
      wrapper = ReleasecopService::ResultWrapper.new("x") { raise "fetch https://user:s3cret@github.com/a/b.git failed" }
      expect(wrapper.error.message).not_to include("s3cret")
    end
  end

  describe ".git!" do
    it "times out a hung command" do
      stub_const("ReleasecopService::GIT_TIMEOUT", 1)
      expect { ReleasecopService.git!("-c", "alias.hang=!sleep 30", "hang", chdir: Dir.tmpdir) }
        .to raise_error(ReleasecopService::GitTimeout, /timed out after 1s/)
    end

    it "turns off auto-gc" do
      expect(ReleasecopService.git!("config", "--get", "gc.auto", chdir: Dir.tmpdir).strip).to eq("0")
    end

    it "keeps credentials out of the error" do
      expect { ReleasecopService.git!("ls-remote", "https://user:s3cret@127.0.0.1:9/x.git", chdir: Dir.tmpdir) }
        .to raise_error(ReleasecopService::GitError) { |e| expect(e.message).not_to include("s3cret") }
    end
  end
end
