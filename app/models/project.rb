class Project < ApplicationRecord
  belongs_to :organization
  has_many :stages
  has_many :snapshots
  belongs_to :snapshot, optional: true
end
