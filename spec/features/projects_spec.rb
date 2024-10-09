# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Projects", type: :feature do
  let(:org) { Organization.create! name: "Artsy" }
  let(:releasecop_comparison) do
    double("Releasecop::Comparison",
           ahead: double("Releasecop::ManifestItem", name: "main"),
           behind: double("Releasecop::ManifestItem", name: "production"),
           unreleased?: true,
           lines: ["commit foo", "commit bar"])
  end

  scenario "view projects" do
    project = org.projects.create!(name: "shipping")
    org.projects.create!(name: "scheduling", tags: ["logistics"])
    project.stages.create!(name: "main")
    project.stages.create!(name: "production")
    Organization.create!(name: "Etsy").projects.create!(name: "foo_php", tags: nil)

    visit "/"
    expect(page).to have_selector 'div[id="projects_data"]'
    props = find('div[id="projects_data"]')["data-props"].as_json
    expect(props).to have_content("Foo Php")
    expect(props).to have_content("Shipping")
    expect(props).to have_content("Scheduling")

    # view diffs...
    allow_any_instance_of(Releasecop::Checker).to receive(:check).and_return(
      Releasecop::Result.new("shipping", [releasecop_comparison])
    )
    ComparisonService.new(project).refresh_comparisons
    visit projects_path(organization_id: org.id)
    expect(page).to have_selector 'div[id="projects_data"]'
    props_with_comparison = find('div[id="projects_data"]')["data-props"].as_json
    expect(props_with_comparison).to have_content('"comparedStages":[{"stages":[{"id":')
    expect(props_with_comparison).to have_content('"description":["commit foo","commit bar"]')

    # only persist new snapshots upon changes
    expect do
      ComparisonService.new(project).refresh_comparisons
    end.not_to change(Snapshot, :count)
  end
end
