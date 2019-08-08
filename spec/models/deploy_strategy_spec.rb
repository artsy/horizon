require 'rails_helper'

RSpec.describe DeployStrategy, type: :model do
  let(:org) { Organization.create!(name: 'artsy') }
  let(:project) { org.projects.create!(name: 'candela') }
  let(:stages) { (1..2).map {|i| project.stages.create!(name: "stage #{i}", git_remote: 'https://github.com/artsy/candela.git') } }

  it 'has an associated github pull request deploy strategy' do
    strategy = stages.last.deploy_strategies.create!(
      provider: 'github pull request',
      automatic: true,
      arguments: {
        base: 'release',
        head: 'staging'
      }
    )
    expect(strategy.stage).to eq(stages.last)
    expect(strategy.github_repo).to eq('artsy/candela')
    expect(strategy).to be_automatic
  end

  it 'respects configured repo name' do
    strategy = stages.last.deploy_strategies.create!(
      provider: 'github pull request',
      automatic: true,
      arguments: {
        repo: 'artsy/candela-foo',
        base: 'release',
        head: 'staging'
      }
    )
    expect(strategy.github_repo).to eq('artsy/candela-foo')
  end

  it 'rejects unsupported providers' do
    expect(stages.last.deploy_strategies.new(
      provider: 'heroku'
    )).not_to be_valid
  end

  it 'requires expected arguments for github pull request provider' do
    expect do
      stages.last.deploy_strategies.create!(
        provider: 'github pull request',
        arguments: { foo: 'bar' }
      )
    end.to raise_error(/can only include base, head, and repo/)
  end
end
