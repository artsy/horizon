# frozen_string_literal: true

require "open3"

class ReleasecopService
  attr_accessor :project

  # format criteria: %h %ad %s (%an, %ae)
  # see https://github.com/joeyAghion/releasecop/blob/master/lib/releasecop/comparison.rb#L5
  LOG_LINE_EXPR = /^(?<sha>[0-9a-f]+) (?<date>[0-9-]+) (?<message>.*) \((?<name>.*), (?<email>.*)\)\w*$/

  FETCH_THREADS = 8
  GIT_TIMEOUT = 60 # seconds per git command, so one slow repo fails its project instead of the whole run
  CLONE_TIMEOUT = 300 # seconds; a first full clone of a large repo takes longer than a fetch
  SLOW_FETCH = 15 # seconds; fetches slower than this get a log line

  class GitError < StandardError; end

  class GitTimeout < GitError; end

  def self.parsed_log_line(line)
    line.match(LOG_LINE_EXPR)&.named_captures&.with_indifferent_access || {}
  end

  # Fetches every project's repo into working_dir, FETCH_THREADS at a time, before the
  # (sequential) comparisons run. Returns {project_id => error or nil} for perform_comparison.
  def self.fetch_all(projects, working_dir)
    FileUtils.mkdir_p(working_dir)
    results = {}
    jobs = Hash.new { |h, name| h[name] = [] }
    projects.each do |p| # DB reads stay on this thread
      items = new(p).manifest_items
      jobs[p.name] << [p.id, items] if items.any? { |i| i["git"].present? }
    rescue => e
      results[p.id] = e # a bad stage fails its own project, not the whole run
    end
    queue = Queue.new
    jobs.each { |name, list| queue << [name, list] } # projects sharing a name share a dir, so one thread runs them
    queue.close
    lock = Mutex.new
    started = Time.now
    Array.new(FETCH_THREADS) do
      Thread.new do
        while (job = queue.pop)
          name, list = job
          list.each do |id, items|
            error = begin
              sync_repo(working_dir, name, items)
              nil
            rescue => e
              e
            end
            lock.synchronize { results[id] = error }
          end
        end
      end
    end.each(&:join)
    Rails.logger.info "[releasecop] fetched #{results.size} projects in #{(Time.now - started).round}s, " \
      "#{results.values.compact.size} failed"
    results
  end

  # Clones the repo if needed, then fetches only the branches the stages compare, once per remote URL.
  def self.sync_repo(working_dir, name, items)
    items = items.select { |i| i["git"].present? }
    return if items.empty?

    repo = File.join(working_dir, name)
    clone_repo(working_dir, name, items) unless Dir.exist?(repo)
    items.group_by { |i| i["git"] }.each do |url, group|
      refspecs = group.select { |i| fetches_branch?(i) }.map { |i| "+refs/heads/#{branch(i)}:refs/remotes/#{i["name"]}/#{branch(i)}" }.uniq
      # forced, so a tag moved on the remote updates instead of failing the fetch
      refspecs << "+refs/tags/*:refs/tags/*" if group.any? { |i| i["tag_pattern"].present? }
      next if refspecs.empty? # hokusai SHAs are fetched by Checker#ensure_commit!

      started = Time.now
      git!("fetch", "--quiet", url, *refspecs, chdir: repo)
      took = Time.now - started
      Rails.logger.info "[releasecop] slow fetch: #{name} took #{took.round(1)}s" if took > SLOW_FETCH
    end
  end

  # Non-bare, like Horizon has always cloned (build_manifest_item always sets "hokusai", so
  # Releasecop::Checker never went bare): a later hokusai stage needs ./hokusai/config.yml on disk.
  # Cloned into a temp name so a clone that times out isn't mistaken for a repo on the next run.
  def self.clone_repo(working_dir, name, items)
    tmp = "#{name}.cloning"
    FileUtils.rm_rf(File.join(working_dir, tmp))
    git!("clone", "--quiet", items.first["git"], tmp, chdir: working_dir, timeout: CLONE_TIMEOUT)
    File.rename(File.join(working_dir, tmp), File.join(working_dir, name))
  end

  # A tag or hokusai stage compares a SHA; its branch is only releasecop's fallback and may not
  # exist on the remote (e.g. impulse's 2018 stages: branch "staging" plus hokusai "staging").
  def self.fetches_branch?(item)
    item["tag_pattern"].blank? && item["hokusai"].blank?
  end

  def self.branch(item)
    item["branch"].presence || ENV["RELEASECOP_DEFAULT_BRANCH"] || "master" # same default as Releasecop::ManifestItem
  end

  def self.git!(*args, chdir:, timeout: GIT_TIMEOUT)
    # no auto-gc: it detaches, the pod kills it on exit, and its leftover gc.log.lock blocks gc for good
    Open3.popen2e("git", "-c", "gc.auto=0", *args, chdir: chdir, pgroup: true) do |stdin, out, wait|
      stdin.close
      reader = Thread.new { out.read }
      reader.report_on_exception = false
      unless wait.join(timeout)
        kill_group(wait)
        raise GitTimeout, "git #{args.first} timed out after #{timeout}s"
      end
      output = reader.value
      status = wait.value
      return output if status.success?

      raise GitError, "git #{args.first} exited #{status.exitstatus || "on signal #{status.termsig}"}: " \
        "#{redact(output.lines.last(3).join.squish)}"
    end
  end

  # TERM first: git removes its lock files on TERM. The group includes git-remote-https.
  def self.kill_group(wait)
    Process.kill("TERM", -wait.pid)
    Process.kill("KILL", -wait.pid) unless wait.join(5)
  rescue Errno::ESRCH
    nil
  end

  def self.redact(text)
    text.to_s.gsub(%r{//[^/@\s]+@}, "//***@")
  end

  def initialize(project, fetched: nil)
    @project = project
    @fetched = fetched
  end

  def perform_comparison
    working_dir = Horizon.config[:working_dir]

    if working_dir
      FileUtils.mkdir_p(working_dir)
      perform_comparison_in_dir(working_dir)
    else
      Dir.mktmpdir(["releasecop", project.name]) do |dir|
        perform_comparison_in_dir(dir)
      end
    end
  end

  def manifest_items
    project.stages.order(position: :asc).map { |s| build_manifest_item(s) }
  end

  class ResultWrapper
    attr_accessor :result, :error

    def initialize(project_name)
      @result = yield
    rescue => e
      self.error = e.exception(ReleasecopService.redact(e.message)) # also stored as the snapshot's error_message
      Rails.logger.warn "[releasecop] #{project_name} failed: #{e.class}: #{error.message}"
    end

    def comparisons
      @result&.comparisons || []
    end
  end

  # Releasecop::Checker#check without its clone and per-stage `git fetch` (see sync_repo).
  class Checker
    def initialize(name, items, working_dir)
      @name = name
      @items = items
      @working_dir = working_dir
    end

    def check
      Dir.chdir(File.join(@working_dir, @name)) do
        envs = @items.map { |i| [Releasecop::ManifestItem.new(@name, i), i] }
        envs.each { |env, item| ensure_commit!(env, item) }
        comparisons = envs.map(&:first).each_cons(2).map { |ahead, behind| Releasecop::Comparison.new(ahead, behind) }
        comparisons.each(&:check)
        Releasecop::Result.new(@name, comparisons)
      end
    end

    private

    # releasecop used to fetch every branch, so a deployed SHA (hokusai or tag_pattern) was usually
    # present. sync_repo fetches only the compared branches, so fetch a missing SHA directly.
    def ensure_commit!(env, item)
      rev = begin
        env.for_rev_range
      rescue NoMethodError
        raise unless item["hokusai"].present?
        # releasecop's find_hokusai_sha calls nil.detect when no image has the stage's tag
        raise GitError, "no hokusai image tagged #{item["hokusai"]} found for stage #{env.name}"
      end
      sha = rev.to_s.match?(/\A\h{40}\z/)
      # releasecop falls back to <stage>/<branch>, which sync_repo didn't fetch, so it would be stale
      raise GitError, "no deployed SHA found for stage #{env.name}" unless sha || ReleasecopService.fetches_branch?(item)
      fetch_sha(env, item, rev) if sha && !commit?(rev)
    end

    def fetch_sha(env, item, rev)
      ReleasecopService.git!("fetch", "--quiet", item["git"], rev, chdir: Dir.pwd)
    rescue GitTimeout
      raise
    rescue GitError => e
      # as before this change: an unknown SHA makes `git log` print nothing
      Rails.logger.warn "[releasecop] #{@name}: could not fetch #{rev} for stage #{env.name}: #{e.message}"
    end

    def commit?(rev)
      ReleasecopService.git!("rev-parse", "--verify", "--quiet", "#{rev}^{commit}", chdir: Dir.pwd)
      true
    rescue GitError
      false
    end
  end

  private

  def construct_git(stage)
    if stage.profile&.basic_username || stage.profile&.basic_password
      uri = URI(stage.git_remote)
      uri.user = stage.profile&.basic_username
      uri.password = stage.profile&.basic_password
      uri.to_s
    else
      stage.git_remote
    end
  end

  def build_manifest_item(stage)
    {
      "name" => stage.name,
      "git" => construct_git(stage),
      "tag_pattern" => stage.tag_pattern.presence,
      "branch" => stage.branch.presence,
      "hokusai" => stage.hokusai.presence,
      "aws_access_key_id" => stage.profile&.environment&.fetch("AWS_ACCESS_KEY_ID"),
      "aws_secret_access_key" => stage.profile&.environment&.fetch("AWS_SECRET_ACCESS_KEY")
    }
  end

  def perform_comparison_in_dir(working_dir)
    items = manifest_items
    ResultWrapper.new(project.name) do
      if @fetched&.key?(project.id)
        raise @fetched[project.id] if @fetched[project.id] # fetch_all failed; ResultWrapper logs it
      else
        self.class.sync_repo(working_dir, project.name, items)
      end
      Checker.new(project.name, items, working_dir).check
    end
  end
end
