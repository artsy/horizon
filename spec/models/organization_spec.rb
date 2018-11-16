require 'rails_helper'

RSpec.describe Organization, type: :model do
  it 'can be deleted despite associations' do
    org = Organization.create!(name: 'artsy')
    project = org.projects.create!(name: 'eigen')
    stages = (1..2).map {|i| project.stages.create!(name: "stage #{i}", git_remote: 'https://github.com/artsy/eigen.git') }
    snapshot = project.snapshots.create!
    comparison = snapshot.comparisons.create!(ahead_stage: stages.first, behind_stage: stages.last)
    org.destroy
  end
end
