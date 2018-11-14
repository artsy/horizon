class Snapshot < ApplicationRecord
  belongs_to :project
  has_many :comparisons, dependent: :destroy
end
