# frozen_string_literal: true

class Project < ApplicationRecord
  include JsonbEditable

  belongs_to :organization
  has_many :stages, dependent: :destroy
  has_many :snapshots, dependent: :destroy
  has_many :deploy_blocks
  belongs_to :snapshot, optional: true

  jsonb_editable :tags
end
