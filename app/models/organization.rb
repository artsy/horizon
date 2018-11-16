class Organization < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :profiles, dependent: :destroy
end
