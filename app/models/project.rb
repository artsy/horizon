class Project < ApplicationRecord
  belongs_to :organization
  has_many :stages
end
