require 'rails_helper'

RSpec.feature "Organizations", type: :feature do
  let(:org) { Organization.create! name: 'Artsy' }
  let(:releasecop_comparison) do
    double('Releasecop::Comparison',
      ahead: double('Releasecop::ManifestItem', name: 'master'),
      behind: double('Releasecop::ManifestItem', name: 'production'),
      :unreleased? => true,
      lines: ['commit foo', 'commit bar']
    )
  end
  let(:large_comparison) do
    double('Releasecop::Comparison',
      ahead: double('Releasecop::ManifestItem', name: 'master'),
      behind: double('Releasecop::ManifestItem', name: 'production'),
      :unreleased? => true,
      lines: (0..20).map { |i| "commit #{i}" }
    )
  end


  scenario 'view organizations and projects' do
    project = org.projects.create!(name: 'shipping')
    project.stages.create!(name: 'master')
    project.stages.create!(name: 'production')
    Organization.create!(name: 'Etsy').projects.create!(name: 'foo_php')

    visit '/'
    expect(page).to have_content('Artsy')

    click_link 'detail', match: :first
    expect(page).to have_content('shipping')
    expect(page).not_to have_content('foo_php')
    expect(page).to have_content('master')
    expect(page).to have_content('production')

    # view diffs...
    allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
      Releasecop::Result.new('shipping', [releasecop_comparison])
    )
    ComparisonService.new(project).refresh_comparisons
    visit projects_path(organization_id: org.id)
    expect(page).to have_content('commit foo')
    expect(page).to have_content('commit bar')

    # only persist new snapshots upon changes
    expect {
      ComparisonService.new(project).refresh_comparisons
    }.not_to change(Snapshot, :count)
  end


  it 'cleans up old snapshots' do
    project = org.projects.create!(name: 'shipping')
    ahead = project.stages.create!(name: 'master')
    behind = project.stages.create!(name: 'production')
    snapshots = 5.times.map do |i|
      project.snapshots.create!(refreshed_at: Time.now + i.days).tap do |snapshot|
        snapshot.comparisons.create!(ahead_stage: ahead, behind_stage: behind, released: false, description: [i])
      end
    end
    expect(project.snapshots.size).to eq(5)
    allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
      Releasecop::Result.new('shipping', [releasecop_comparison])
    )
    ComparisonService.new(project).refresh_comparisons
    expect(project.snapshots.size).to eq(5)
    expect(Snapshot.where(id: snapshots.first.id).count).to eq(0)
  end

  context 'deploys' do
    it 'deploys when warranted and automatic' do
      project = org.projects.create!(name: 'shipping')
      project.stages.create!(name: 'master')
      prod = project.stages.create!(name: 'production')
      profile = org.profiles.create!(basic_password: 'foo')
      prod.deploy_strategies.create!(
        provider: 'github pull request',
        profile: profile,
        automatic: true,
        arguments: { base: 'release', head: 'staging ' }
      )
      allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
        Releasecop::Result.new('shipping', [large_comparison])
      )
      expect(DeployService).to receive(:start)
      ComparisonService.new(project).refresh_comparisons
    end

    it 'does nothing unless warranted' do
      project = org.projects.create!(name: 'shipping')
      project.stages.create!(name: 'master')
     prod = project.stages.create!(name: 'production')
      profile = org.profiles.create!(basic_password: 'foo')
      prod.deploy_strategies.create!(
        provider: 'github pull request',
        profile: profile,
        automatic: true,
        arguments: { base: 'release', head: 'staging ' }
      )
      allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
        Releasecop::Result.new('shipping', [releasecop_comparison])
      )
      expect(DeployService).not_to receive(:start)
      ComparisonService.new(project).refresh_comparisons
    end

    it 'does nothing when deploy warranted but automatic is false' do
      project = org.projects.create!(name: 'shipping')
      project.stages.create!(name: 'master')
      prod = project.stages.create!(name: 'production')
      profile = org.profiles.create!(basic_password: 'foo')
      prod.deploy_strategies.create!(
        provider: 'github pull request',
        profile: profile,
        automatic: false,
        arguments: { base: 'release', head: 'staging ' }
      )
      allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
        Releasecop::Result.new('shipping', [large_comparison])
      )
      expect(DeployService).not_to receive(:start)
      ComparisonService.new(project).refresh_comparisons
    end
  end
end
