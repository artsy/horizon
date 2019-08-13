class Snapshot < ApplicationRecord
  belongs_to :project
  has_many :comparisons, dependent: :destroy
  has_one :current_snapshot_for_project, class_name: 'Project', dependent: :nullify # useful for cleaning up Project#snapshot references on destroy
end
