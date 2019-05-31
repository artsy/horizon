class Project < ApplicationRecord
  include JsonbEditable

  belongs_to :organization
  has_many :stages, dependent: :destroy
  has_many :snapshots, dependent: :destroy
  belongs_to :snapshot, optional: true

  jsonb_editable :tags

  def fully_released?
    snapshot && snapshot.error_message.nil? && snapshot.comparisons.all?(&:released?)
  end

  def total_comparison_size
    snapshot&.total_comparison_size || 0
  end
end
