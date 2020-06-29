# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :cron do
  task refresh_comparisons: :environment do
    ComparisonService.refresh_all_comparisons
  end

  task refresh_components: :environment do
    Organization.all.each do |org|
      ProjectDataService.refresh_data_for_org(org)
    end
  end
end

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop)

  desc 'run prettier'
  task prettier: :environment do
    system 'yarn prettier'
    abort 'prettier failed' unless $CHILD_STATUS.exitstatus.zero?
  end

  desc 'run jest'
  task jest: :environment do
    system 'yarn test'
    abort 'jest failed' unless $CHILD_STATUS.exitstatus.zero?
  end

  Rake::Task[:default].clear
  task default: %i[prettier rubocop jest spec]
end
