# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dependency, type: :model do
  let(:org) { Organization.create! name: 'artsy' }
  let(:profile) { org.profiles.create!(basic_password: 'foo') }
  let(:project) { org.projects.create!(name: 'candela') }

  before do
    allow(Horizon)
      .to receive(:config)
      .and_return({
                    minimum_version_ruby: '2.6.6',
                    minimum_version_node: '12.0.0'
                  })
  end

  describe 'update_required?' do
    it 'can identify out of date ruby versions' do
      dependency = Dependency.create!(
        name: 'ruby',
        version: '2.4.3',
        project: project
      )
      expect(dependency.update_required?).to be_truthy
    end

    it 'can verify ruby version is up to date' do
      dependency = Dependency.create!(
        name: 'ruby',
        version: '2.6.6',
        project: project
      )
      expect(dependency.update_required?).to be_falsey
    end

    it 'can identify out of date node versions' do
      dependency = Dependency.create!(
        name: 'node',
        version: '>=8.12.x',
        project: project
      )
      expect(dependency.update_required?).to be_truthy
    end

    it 'can verify node version is up to date' do
      dependency = Dependency.create!(
        name: 'node',
        version: 'v13',
        project: project
      )
      expect(dependency.update_required?).to be_falsey
    end

    it 'can handle unknown versions' do
      dependency = Dependency.create!(
        name: 'node',
        version: 'unknown version',
        project: project
      )
      expect(dependency.update_required?).to be_falsey
    end
  end
end
