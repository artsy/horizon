class DeployBlock < ApplicationRecord
  belongs_to :project

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }
end
