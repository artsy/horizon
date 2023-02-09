# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComparisonService, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let(:org) { Organization.create! name: 'Artsy' }
  let!(:project) do
    org.projects.create!(name: 'shipping').tap do |p|
      p.stages.create!(name: 'main')
      p.stages.create!(name: 'production')
    end
  end

  describe 'refresh_all_comparisons' do
    it 'recovers from releasecop comparison failures' do
      allow_any_instance_of(ComparisonService).to receive(:refresh_comparisons)
        .and_raise(ZeroDivisionError)
      expect { ComparisonService.refresh_all_comparisons }.not_to raise_error
    end
  end

  describe 'refresh_comparisons_for_organizations' do
    it 'works' do
      expect { ComparisonService.refresh_comparisons_for_organization(org) }.not_to raise_error
    end
  end

  describe 'severity_score' do
    before do
      travel_to Time.zone.local(2019, 8, 2, 11, 11, 11)
    end

    let(:one_recent_commit_score) do
      ComparisonService.severity_score(
        [{ email: 'foo@bar.com', date: '2019-08-01' }]
      )
    end

    let(:one_semirecent_commit_score) do
      ComparisonService.severity_score(
        [{ email: 'foo@bar.com', date: '2019-07-31' }]
      )
    end

    let(:one_week_old_commit_score) do
      ComparisonService.severity_score(
        [{ email: 'foo@bar.com', date: '2019-07-25' }]
      )
    end

    let(:one_recent_contributor_score) do
      ComparisonService.severity_score(
        [
          { email: 'foo@bar.com', date: '2019-08-01' },
          { email: 'foo@bar.com', date: '2019-08-02' }
        ]
      )
    end

    let(:two_recent_contributors_score) do
      ComparisonService.severity_score(
        [
          { email: 'foo@bar.com', date: '2019-08-01' },
          { email: 'baz@bar.com', date: '2019-08-02' }
        ]
      )
    end

    let(:two_old_contributors_score) do
      ComparisonService.severity_score(
        [
          { email: 'foo@bar.com', date: '2019-07-20' },
          { email: 'baz@bar.com', date: '2019-07-19' }
        ]
      )
    end

    it 'is 0 for no changes' do
      expect(ComparisonService.severity_score([])).to eq(0)
    end

    it 'is higher for more contributors' do
      expect(two_recent_contributors_score).to be > one_recent_contributor_score
    end

    it 'is higher for old commits' do
      expect(two_old_contributors_score).to be > two_recent_contributors_score
    end

    it 'doubles for each week old' do
      expect(one_semirecent_commit_score).to be > one_recent_commit_score
      expect(one_week_old_commit_score).to be > (2 * one_recent_commit_score)
    end
  end
end
