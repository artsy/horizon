class Stage < ApplicationRecord
  belongs_to :project
  acts_as_list scope: :project
end
