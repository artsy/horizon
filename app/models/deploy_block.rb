# frozen_string_literal: true

class DeployBlock < ApplicationRecord
  belongs_to :project

  scope :unresolved, -> { where(resolved_at: nil).or(where('resolved_at >= ?', DateTime.current)) }
  scope :resolved, -> { where('resolved_at <= ?', DateTime.current) }

  after_save :broadcast_updates

  private

  def broadcast_updates
    return unless id_previously_changed? || resolved_at_previously_changed?

    ActionCable.server.broadcast(ProjectChannel.channel_name(project.organization_id), updatedBlocks: true)
    ActionCable.server.broadcast(ProjectChannel.channel_name, updatedBlocks: true)
  end
end
