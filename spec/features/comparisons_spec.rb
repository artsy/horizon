# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Comparisons", type: :feature do
  let(:org) { Organization.create! name: "Artsy" }
  let(:profile) { org.profiles.create!(basic_password: "foo") }
  let(:project) do
    org.projects.create!(name: "shipping").tap do |p|
      p.stages.create!(name: "main")
      p.stages.create!(name: "production")
    end
  end
  let(:small_comparison) do
    double("Releasecop::Comparison",
      ahead: double("Releasecop::ManifestItem", name: "main"),
      behind: double("Releasecop::ManifestItem", name: "production"),
      unreleased?: true,
      lines: ["commit foo", "commit bar"])
  end
  let(:large_comparison) do
    double("Releasecop::Comparison",
      ahead: double("Releasecop::ManifestItem", name: "main"),
      behind: double("Releasecop::ManifestItem", name: "production"),
      unreleased?: true,
      lines: (0..20).map { |i| "commit #{i}" })
  end
  let(:empty_comparison) do
    double("Releasecop::Comparison",
      ahead: double("Releasecop::ManifestItem", name: "main"),
      behind: double("Releasecop::ManifestItem", name: "production"),
      unreleased?: false,
      lines: [])
  end

  it "cleans up old snapshots" do
    snapshots = 5.times.map do |i|
      project.snapshots.create!(refreshed_at: Time.now + i.days).tap do |snapshot|
        snapshot.comparisons.create!(
          ahead_stage: project.stages.first,
          behind_stage: project.stages.last,
          released: false,
          description: [i]
        )
      end
    end
    expect(project.snapshots.size).to eq(5)
    allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
      Releasecop::Result.new("shipping", [small_comparison])
    )
    ComparisonService.new(project).refresh_comparisons
    expect(project.snapshots.size).to eq(5)
    expect(Snapshot.where(id: snapshots.first.id).count).to eq(0)
  end

  context "deploys" do
    it "deploys when warranted and automatic" do
      project.stages.last.deploy_strategies.create!(
        provider: "github pull request",
        profile: profile,
        automatic: true,
        arguments: {base: "release", head: "staging"}
      )
      allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
        Releasecop::Result.new("shipping", [large_comparison])
      )
      expect_any_instance_of(DeployService).to receive(:start)
      ComparisonService.new(project).refresh_comparisons
    end

    it "does nothing when deploy unwarranted" do
      project.stages.last.deploy_strategies.create!(
        provider: "github pull request",
        profile: profile,
        automatic: true,
        arguments: {base: "release", head: "staging"}
      )
      allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
        Releasecop::Result.new("shipping", [empty_comparison])
      )
      expect_any_instance_of(DeployService).not_to receive(:start)
      ComparisonService.new(project).refresh_comparisons
    end

    it "does nothing when deploy warranted but automatic is false" do
      project.stages.last.deploy_strategies.create!(
        provider: "github pull request",
        profile: profile,
        automatic: false,
        arguments: {base: "release", head: "staging"}
      )
      allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
        Releasecop::Result.new("shipping", [large_comparison])
      )
      expect_any_instance_of(DeployService).not_to receive(:start)
      ComparisonService.new(project).refresh_comparisons
    end

    it "does nothing when the project has unresolved deploy blocks" do
      project.stages.last.deploy_strategies.create!(
        provider: "github pull request",
        profile: profile,
        automatic: true,
        arguments: {base: "release", head: "staging"}
      )
      allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
        Releasecop::Result.new("shipping", [large_comparison])
      )
      project.deploy_blocks.create!(description: "staging broken")
      expect_any_instance_of(DeployService).not_to receive(:start)
      ComparisonService.new(project).refresh_comparisons
    end
  end
end
