# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if ENV['ARTSY_ENV']
  $stderr.puts 'Sourcing seed data from shared Artsy environment variables.'
else
  $stderr.puts 'No shared Artsy environment found. Falling back to defaults.'
end

artsy_org = Organization.create!(name: 'artsy')

github_aws_profile = artsy_org.profiles.create!(
  name: 'github/aws',
  basic_username: 'github',
  basic_password: ENV['ARTSY_GITHUB_TOKEN'] || '<github_token>',
  environment: {
    'AWS_ACCESS_KEY_ID' => ENV['ARTSY_AWS_ACCESS_KEY_ID'] || '<aws_id>',
    'AWS_SECRET_ACCESS_KEY' => ENV['ARTSY_AWS_SECRET_ACCESS_KEY'] || '<aws_secret>'
  }
)
heroku_profile = artsy_org.profiles.create!(
  name: 'heroku',
  basic_username: 'heroku',
  basic_password: ENV['ARTSY_HEROKU_TOKEN'] || '<heroku_token>'
)

candela_project = artsy_org.projects.create!(
  name: 'candela',
  description: 'send analytics data based on warehouse data',
  tags: ['galleries', 'auctions']
)
main_stage = candela_project.stages.create!(
  name: 'main',
  git_remote: 'https://github.com/artsy/candela.git',
  profile: github_aws_profile
)
staging_stage = candela_project.stages.create!(
  name: 'staging',
  git_remote: 'https://github.com/artsy/candela.git',
  profile: github_aws_profile,
  hokusai: 'staging'
)
production_stage = candela_project.stages.create!(
  name: 'production',
  git_remote: 'https://github.com/artsy/candela.git',
  profile: github_aws_profile,
  hokusai: 'production'
)
production_stage.deploy_strategies.create!(
  provider: 'github pull request',
  profile: github_aws_profile,
  automatic: true,
  arguments: { base: 'release', head: 'staging' }
)
snapshot = candela_project.snapshots.create!(refreshed_at: 5.minutes.ago)
snapshot.comparisons.create!(
  behind_stage: production_stage,
  ahead_stage: staging_stage,
  released: false,
  description: [
    'e033cf057 2020-07-20 Update prop name for clarity (Will Willson, will@example.com)',
    '0401b9ffb 2020-07-17 Jest Force Garbage Collection (Tina Tinason, tina@example.com)'
  ]
)
snapshot.comparisons.create!(
  behind_stage: staging_stage,
  ahead_stage: main_stage,
  released: true,
  description: []
)
candela_project.update!(snapshot: snapshot)
candela_project.deploy_blocks.create!(description: 'an example deploy block')

charge_project = artsy_org.projects.create!(
  name: 'charge',
  description: 'create and pay auction invoices',
  tags: ['auctions']
)
charge_main_stage = charge_project.stages.create!(
  name: 'main',
  git_remote: 'https://github.com/artsy/charge.git',
  profile: github_aws_profile
)
charge_staging_stage = charge_project.stages.create!(
  name: 'staging',
  git_remote: 'https://git.heroku.com/charge-staging.git',
  profile: heroku_profile
)
charge_production_stage = charge_project.stages.create!(
  name: 'production',
  git_remote: 'https://git.heroku.com/charge-production.git',
  profile: heroku_profile
)
