require 'rails_helper'

RSpec.feature "Organizations", type: :feature do
  let(:org) { Organization.create! name: 'Artsy' }
  let(:releasecop_comparison) do
    double('Releasecop::Comparison',
      ahead: double('Releasecop::ManifestItem', name: 'master'),
      behind: double('Releasecop::ManifestItem', name: 'staging'),
      :unreleased? => true,
      lines: ['commit foo', 'commit bar']
    )
  end

  scenario 'view organizations and projects' do
    project = org.projects.create!(name: 'shipping')
    project.stages.create!(name: 'master')
    project.stages.create!(name: 'staging')
    Organization.create!(name: 'Etsy').projects.create!(name: 'foo_php')

    visit '/'
    expect(page).to have_content('Artsy')

    click_link 'Artsy'
    expect(page).to have_content('shipping')
    expect(page).not_to have_content('foo_php')
    expect(page).to have_content('master')
    expect(page).to have_content('staging')

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
    behind = project.stages.create!(name: 'staging')
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
end
