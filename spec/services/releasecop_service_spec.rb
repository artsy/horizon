# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define :a_tmp_dir do
  match do |actual|
    actual =~ /.*releasecop.*/ # pattern used by ReleasecopService
  end
end

RSpec.describe ReleasecopService, type: :service do
  include ActiveSupport::Testing::TimeHelpers
  let(:org) { Organization.create! name: 'Artsy' }
  let(:project) do
    org.projects.create!(name: 'shipping').tap do |p|
      p.stages.create!(name: 'master')
      p.stages.create!(name: 'production')
    end
  end

  describe 'working dir not set by user' do
    it 'uses a temp dir' do
      obj = ReleasecopService.new(project)
      expect(obj).to receive(:perform_comparison_in_dir).with(a_tmp_dir)
      obj.perform_comparison
    end
  end

  describe 'working dir set by user' do
    it 'uses user-specified dir' do
      Dir.mktmpdir(['user_specified_dir']) do |dir| # using mktmpdir b/c it cleans up after
        allow(Horizon)
          .to receive(:config)
          .and_return({ working_dir: dir })
        obj = ReleasecopService.new(project)
        expect(obj).to receive(:perform_comparison_in_dir).with(dir)
        obj.perform_comparison
      end
    end
  end
end
