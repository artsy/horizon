# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  it 'can be deleted despite associations' do
    org = Organization.create!(name: 'artsy')
    project = org.projects.create!(name: 'eigen')
    stages = (1..2).map do |i|
      project.stages.create!(
        name: "stage #{i}",
        git_remote: 'https://github.com/artsy/eigen.git'
      )
    end
    snapshot = project.snapshots.create!
    snapshot.comparisons.create!(ahead_stage: stages.first, behind_stage: stages.last)
    project.update(snapshot: snapshot)
    expect(project.destroy).to be_present
  end
end
