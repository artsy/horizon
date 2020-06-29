# frozen_string_literal: true

class Project < ApplicationRecord
  include JsonbEditable

  belongs_to :organization
  has_many :stages, dependent: :destroy
  has_many :snapshots, dependent: :destroy
  has_many :deploy_blocks
  belongs_to :snapshot, optional: true
  has_many :dependencies, dependent: :destroy

  jsonb_editable :tags

  def github_repo
    [organization.name, name].join('/')
  end
end
