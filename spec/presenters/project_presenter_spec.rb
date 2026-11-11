# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectPresenter do
  let(:project) { Organization.create!(name: "Artsy").projects.create!(name: "shipping") }

  it "is fully released when the snapshot has no error and nothing is behind" do
    project.update!(snapshot: project.snapshots.create!)
    expect(described_class.new(project).fully_released?).to be_truthy
  end

  it "is not fully released when the snapshot has an error" do
    project.update!(snapshot: project.snapshots.create!(error_message: "git fetch exited 128"))
    expect(described_class.new(project).fully_released?).to be_falsey
  end
end
