class Comparison < ApplicationRecord
  belongs_to :snapshot
  belongs_to :ahead_stage, class_name: 'Stage'
  belongs_to :behind_stage, class_name: 'Stage'

  acts_as_list scope: :snapshot
end
