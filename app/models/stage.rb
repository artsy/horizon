class Stage < ApplicationRecord
  belongs_to :project
  belongs_to :profile, optional: true

  acts_as_list scope: :project
end
