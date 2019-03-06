class Profile < ApplicationRecord
  include JsonbEditable

  belongs_to :organization

  jsonb_editable :environment
end
