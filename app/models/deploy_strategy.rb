class DeployStrategy < ApplicationRecord
  belongs_to :stage
  validate :validate_arguments

  REQUIRED_ARGUMENTS = {
    'github pull request' => %w[base head]
  }

  SUPPORTED_ARGUMENTS = {
    'github pull request' => %w[base head repo]
  }

  def github_repo
    arguments['repo'] || [stage.project.organization.name, stage.project.name].join('/')
  end

  private

  def validate_arguments
    unless REQUIRED_ARGUMENTS[provider].all? { |a| arguments.keys.include?(a) }
      errors.add(:arguments, "must include #{REQUIRED_ARGUMENTS[provider].to_sentence}")
    end
    unless arguments.keys.all? { |a| SUPPORTED_ARGUMENTS[provider].include?(a) }
      errors.add(:arguments, "can only include #{SUPPORTED_ARGUMENTS[provider].to_sentence}")
    end
  end
end
