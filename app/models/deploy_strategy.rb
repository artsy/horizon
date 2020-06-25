# frozen_string_literal: true

class DeployStrategy < ApplicationRecord
  include JsonbEditable

  PROVIDERS = ['github pull request'].freeze
  REQUIRED_ARGUMENTS = {
    'github pull request' => %w[base head]
  }.freeze
  SUPPORTED_ARGUMENTS = {
    'github pull request' => %w[base head repo]
  }.freeze

  belongs_to :stage
  belongs_to :profile, optional: true
  validates :provider, inclusion: { in: PROVIDERS }
  validate :validate_arguments

  jsonb_editable :arguments

  # Prefer a `repo` argument, but fall back to org and project names otherwise.
  def github_repo
    arguments['repo'] || [stage.project.organization.name, stage.project.name].join('/')
  end

  private

  def validate_arguments # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
    return unless PROVIDERS.include?(provider) # don't bother if provider invalid

    unless REQUIRED_ARGUMENTS[provider].all? { |a| (arguments || {}).keys.include?(a) }
      errors.add(:arguments, "must include #{REQUIRED_ARGUMENTS[provider].to_sentence}")
    end
    unless (arguments || {}).keys.all? { |a| SUPPORTED_ARGUMENTS[provider].include?(a) } # rubocop:disable Style/GuardClause
      errors.add(:arguments, "can only include #{SUPPORTED_ARGUMENTS[provider].to_sentence}")
    end
  end
end
