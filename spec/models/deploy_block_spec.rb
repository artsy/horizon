# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeployBlock, type: :model do
  let(:org) { Organization.create!(name: 'artsy') }
  let(:project) { org.projects.create!(name: 'candela') }

  describe 'websocket broadcasts' do
    it 'broadcasts on creation' do
      expect(ActionCable.server).to receive(:broadcast).with(
        "organization:#{org.id}", updatedBlocks: true
      )
      expect(ActionCable.server).to receive(:broadcast).with(
        'organization:-1', updatedBlocks: true
      )
      project.deploy_blocks.create!(description: 'broken')
    end

    it 'broadcasts on resolution' do
      block = project.deploy_blocks.create!(description: 'broken')
      expect(ActionCable.server).to receive(:broadcast).with(
        "organization:#{org.id}", updatedBlocks: true
      )
      expect(ActionCable.server).to receive(:broadcast).with(
        'organization:-1', updatedBlocks: true
      )
      block.update!(resolved_at: Time.now)
    end

    it 'does nothing upon uninteresting updates' do
      block = project.deploy_blocks.create!(description: 'broken', resolved_at: Time.now)
      expect(ActionCable.server).not_to receive(:broadcast)
      block.update!(description: 'not broken anymore')
    end
  end
end
