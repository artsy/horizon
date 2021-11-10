# frozen_string_literal: true

class DeployStrategy < ApplicationRecord
  include JsonbEditable

  PROVIDERS = ['github pull request'].freeze
  REQUIRED_ARGUMENTS = {
    'github pull request' => %w[base head]
  }.freeze
  SUPPORTED_ARGUMENTS = {
    'github pull request' => [
      'base', # e.g., "release"
      'head', # e.g., "staging"
      'repo', # e.g., "artsy/candela"
      'merge_after', # seconds after which to automatically merge release PRs (default 86400 or 24 hours)
      'merge_prior_warning', # when to notify slack about a pending merge, in seconds (default 3600 or 1 hour)
      'slack_webhook_url', # for notifying prior to merging release PRs
      'warned_pull_request_url', # used internally to avoid repeat notifications
      'blocked_time_buckets' # a list of cron expr that allows to block merge deploys into an specific part of the day
    ]
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

  def validate_arguments
    return unless PROVIDERS.include?(provider) # don't bother if provider invalid

    unless REQUIRED_ARGUMENTS[provider].all? { |a| (arguments || {}).keys.include?(a) }
      errors.add(:arguments, "must include #{REQUIRED_ARGUMENTS[provider].to_sentence}")
    end
    return if (arguments || {}).keys.all? { |a| SUPPORTED_ARGUMENTS[provider].include?(a) }

    errors.add(:arguments, "can only include #{SUPPORTED_ARGUMENTS[provider].to_sentence}")
  end
end
