# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  let(:org) { Organization.create! name: "artsy" }
  let(:profile) { org.profiles.create!(basic_password: "foo") }
  let(:project) { org.projects.create!(name: "eigen-ios") }

  before do
    (1..2).map do |i|
      project.stages.create!(
        name: "stage #{i}",
        git_remote: "https://github.com/artsy/eigen.git",
        profile: profile
      )
    end

    allow(Horizon)
      .to receive(:config)
      .and_return({
        minimum_version_ruby: "2.6.6",
        minimum_version_node: "12.0.0"
      })
  end

  it "can be deleted despite associations" do
    snapshot = project.snapshots.create!
    project.deploy_blocks.create!
    snapshot.comparisons.create!(ahead_stage: project.stages.first, behind_stage: project.stages.last)
    project.update(snapshot: snapshot)
    expect(project.destroy).to be_present
  end

  describe "github_repo" do
    it "draws from git remote when possible" do
      expect(project.github_repo).to eq("artsy/eigen")
    end

    it "falls back to org and project name" do
      expect(Project.new(organization: org, name: "hubble").github_repo).to eq("artsy/hubble")
    end
  end

  describe "default: main" do
    it "can still find the git remote" do
      project.stages.first.update(name: "main")
      expect(project.git_remote).to eq "https://github.com/artsy/eigen.git"
    end
  end

  describe "deployment_type" do
    it "returns kubernetes when project uses hokusai" do
      project.stages.first.update(hokusai: "staging")
      expect(project.deployment_type).to eq "kubernetes"
    end

    it "returns heroku when project profile is heroku" do
      profile.update(name: "heroku")
      expect(project.deployment_type).to eq "heroku"
    end
  end

  describe "kubernetes?" do
    it "returns true when project uses hokusai" do
      project.stages.first.update(hokusai: "staging")
      expect(project.deployment_type).to eq "kubernetes"
    end

    it "returns false when project does not use hokusai" do
      project.stages.first.update(hokusai: nil)
      expect(project.deployment_type).to be_falsey
    end
  end

  describe "auto_deploys?" do
    it "returns true when auto deploy prs are enabled" do
      project.stages.last.deploy_strategies.create!(
        provider: "github pull request",
        profile: profile,
        automatic: true,
        arguments: {base: "release", head: "staging "}
      )
      expect(project.auto_deploys?).to be_truthy
    end
  end

  describe "dependencies_up_to_date?" do
    it "returns true if all up to date" do
      project.dependencies.create!(
        name: "ruby",
        version: "2.6.6"
      )
      expect(project.dependencies_up_to_date?).to be_truthy
    end
  end
end
