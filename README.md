Horizon
===

Visual representations of release pipelines.

* State: internal usage
* Staging (only): [releases.artsy.net](https://releases.artsy.net)
* GitHub: https://github.com/artsy/horizon
* Point Team: [Platform](https://artsy.slack.com/messages/product-platform)
* Deployment: builds of the `master` branch are automatically deployed to staging by CircleCI. There is no production environment.

Features
---
- [Release Dashboard](https://releases.artsy.net/projects?organization_id=1&view=dashboard)
- [Release Detail](https://releases.artsy.net/projects?organization_id=1)
- [Deploy Blockers](https://releases.artsy.net/admin/deploy_blocks)

Design
---
* `Organization`s have many `Project`s
* Each `Project` has an associated list of `Stage`s, with their order determined by `Stage#position` (e.g., _master_, _staging_, and _production_)
* `Stage`s must describe how to get information about their current state. This takes the form of a `#git_remote` (e.g., referring to Github or Heroku), optional `#branch` name (default: _master_), optional `#hokusai` environment (e.g., _staging_ or _production_), or `#tag_pattern` (e.g., _release-*_). The [`releasecop` gem](https://github.com/joeyAghion/releasecop) is used internally to determine stage diffs, so see that project for more detail.
* `Stage`s can optionally be associated with a `Profile` that stores credentials for accessing git providers or AWS.
* `Snapshot`s capture the complete state of a project's stages at a point in time. Each `Snapshot` has associated `Comparison`s between the consecutive stages of a project (e).g., a comparison between _master_ and _staging_, and a second between _staging_ and _production_)
* A cron periodically reevaluates these comparisons, creating a new snapshot if the state has changed at all.

Setup
---

    hokusai dev run 'bundle exec rake db:migrate'
    hokusai dev start

The administrative UI can then be found at http://localhost:3000/admin. Create organizations, projects, profiles, and stages from there. Alternatively, here's an example using the console:

    org = Organization.create!(name: 'Acme')
    website = org.projects.create!(name: 'acme.org')
    heroku = org.profiles.create!(
      name: 'heroku',
      basic_username: 'heroku',
      basic_password: '<heroku_token>'
    )
    github_aws = org.profiles.create!(
      name: 'github/aws',
      basic_username: 'github',
      basic_password: '<github_token>',
      environment: {'AWS_ACCESS_KEY_ID' => '<aws_id>', 'AWS_SECRET_ACCESS_KEY' => '<aws_secret>'}
    )
    website.stages.create!(
      name: 'master',
      git_remote: 'https://github.com/acme/website.git',
      profile: github_aws
    )
    website.stages.create!(
      name: 'staging',
      git_remote: 'https://git.heroku.com/acme-website-staging.git',
      profile: heroku
    )
    website.stages.create!(
      name: 'production',
      git_remote: 'https://git.heroku.com/acme-website-production.git',
      profile: heroku
    )

Once the cron has run, its snapshots are visible from the `/projects` page.

TO DO
---
* ~~Support hokusai~~
* ~~Better visual~~
* ~~Allow SSH keys to be configured for each org or project (probably like `git config --local core.sshCommand "ssh -i ~/.ssh/some_key_file"`...). (Maybe not necessary given github/heroku tokens in https URLs)~~
* ~~sanitize URLs with tokens/credentials in them~~
* ~~instead of including tokens in each git URL, define "profiles" associated with each organization and project~~
* Experiment with programmatic git/hokusai access instead of shelling out
* button to refresh project on-demand
* ~~Fix ugly AWS credentials -> hokusai flow~~
* ~~Make errors [when refreshing projects] visible and avoid short-circuiting entire cron~~
* Make sorting and classifying of projects more sophisticated (penalize staleness and number of contributors and not just number of commits)
* ~~Add tags to projects and enable filtering dashboard/list view by them~~
