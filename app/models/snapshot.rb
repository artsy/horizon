class Snapshot < ApplicationRecord
  belongs_to :project
  has_many :comparisons, dependent: :destroy

  def total_comparison_size
    comparisons.map(&:comparison_size).sum
  end
end
