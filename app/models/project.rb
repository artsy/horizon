# frozen_string_literal: true

class Project < ApplicationRecord
  include JsonbEditable

  GITHUB_REMOTE_EXPR = %r{https://github.com/(?<org>[^/]+)/(?<project>[^.]+).git}.freeze

  belongs_to :organization
  has_many :stages, dependent: :destroy
  has_many :snapshots, dependent: :destroy
  has_many :deploy_blocks
  belongs_to :snapshot, optional: true
  has_many :dependencies, dependent: :destroy

  jsonb_editable :tags

  validates :criticality, inclusion: { in: [0, 1, 2, 3] }, unless: proc { |a| a.criticality.blank? }

  def github_repo
    github_match = stages.ordered.first&.git_remote&.match(GITHUB_REMOTE_EXPR)
    return [organization.name, name].join('/') unless github_match

    "#{github_match[:org]}/#{github_match[:project]}"
  end

  def github_repo_url
    "https://github.com/#{github_repo}"
  end

  def git_remote
    stage = stages&.detect { |main_stage| %w[main master].any? main_stage.name }
    stage&.git_remote
  end

  def block
    blocks = deploy_blocks.unresolved.to_a
    blocks.first
  end

  def auto_deploys?
    stages.any? { |s| s.deploy_strategies.any?(&:automatic?) }
  end

  def kubernetes?
    stages&.any? { |s| s.hokusai&.length&.positive? }
  end

  def heroku?
    stages.any? { |s| s.profile&.name == 'heroku' }
  end

  def deployment_type
    return 'kubernetes' if kubernetes?

    return 'heroku' if heroku?
  end

  def dependencies_up_to_date?
    dependencies_with_unknown_status.empty? && dependencies_with_update_required.empty?
  end

  def dependencies_with_unknown_status
    dependencies.select { |d| d.version.include?('unknown') }
  end

  def dependencies_with_update_required
    dependencies.select(&:update_required?)
  end

  def as_json(_options = nil)
    {
      block: block,
      ciProvider: ci_provider&.titleize,
      criticality: criticality,
      description: description,
      dependencies: dependencies.sort_by(&:name),
      dependenciesUpToDate: dependencies_up_to_date?,
      deploymentType: deployment_type&.titleize,
      gitRemote: git_remote,
      id: id,
      isAutoDeploy: auto_deploys?,
      isKubernetes: kubernetes?,
      name: name.titleize,
      orbs: orbs,
      renovate: renovate,
      stages: stages.sort_by(&:position),
      tags: tags
    }
  end
end
