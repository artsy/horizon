class Profile < ApplicationRecord
  include JsonbEditable

  belongs_to :organization
  has_many :deploy_strategies, dependent: :nullify

  jsonb_editable :environment
end
