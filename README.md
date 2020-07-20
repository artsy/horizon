# Horizon [![CircleCI](https://circleci.com/gh/artsy/horizon.svg?style=svg)](https://circleci.com/gh/artsy/horizon)

Visual representations of release pipelines.

- **State:** Internal usage
- **Production:** [https://releases.artsy.net](https://releases.artsy.net) | [k8s](https://kubernetes.artsy.net/#!/search?q=horizon&namespace=default)
- **Staging:** [https://releases-staging.artsy.net](https://releases-staging.artsy.net) | [k8s](https://kubernetes-staging.artsy.net/#!/search?q=horizon&namespace=default)
- **GitHub:** https://github.com/artsy/horizon
- **CI/Deploys:** [CircleCi](https://circleci.com/gh/artsy/horizon); merged PRs to `artsy/horizon#master` are automatically deployed to staging; PRs from `staging` to `release` are automatically deployed to production. [Start a deploy...](https://github.com/artsy/horizon/compare/release...staging?expand=1)
- **Point Team:** [Platform](https://artsy.slack.com/messages/product-platform)

## Quick links

- [Releases: dashboard view](https://releases.artsy.net/projects?organization_id=1&view=dashboard)
- [Releases: detailed view](https://releases.artsy.net/projects?organization_id=1)
- [View deploy blocks](https://releases.artsy.net/admin/deploy_blocks) or [create a new one](https://releases.artsy.net/admin/deploy_blocks/new)
- [View projects](https://releases.artsy.net/admin/projects) or [create a new one](https://releases.artsy.net/admin/projects/new)

## Setup

With docker:

    hokusai dev run 'bundle exec rake db:migrate'
    hokusai dev start

Or on localhost:

    bundle exec rails db:prepare
    yarn install
    bundle exec rails server

    # run the webpack-dev-server in a seperate terminal window for hot reloading and faster compilation:
    ./bin/webpack-dev-server

The administrative UI can then be found at http://localhost:3000/admin.

To load representative data for development, you have several options:
* Create organizations, projects, profiles, and stages from the administrative UI.
* Run the `db:seed` rake task (or `db:seed:replant` to re-seed). The same command can be run via `hokusai dev run ...` for docker-based development.
* Use the `./bin/pull_data` script to copy data from staging (requires VPN and Artsy developer credentials).

Once the cron has run, its snapshots are visible from the `/projects` page.

## Design

- `Organization`s have many `Project`s
- Each `Project` has an associated list of `Stage`s, with their order determined by `Stage#position` (e.g., _master_, _staging_, and _production_)
- `Stage`s must describe how to get information about their current state. This takes the form of a `#git_remote` (e.g., referring to Github or Heroku), optional `#branch` name (default: _master_), optional `#hokusai` environment (e.g., _staging_ or _production_), or `#tag_pattern` (e.g., _release-\*_). The [`releasecop` gem](https://github.com/joeyAghion/releasecop) is used internally to determine stage diffs, so see that project for more detail.
- `Stage`s can optionally be associated with a `Profile` that stores credentials for accessing git providers or AWS.
- `Snapshot`s capture the complete state of a project's stages at a point in time. Each `Snapshot` has associated `Comparison`s between the consecutive stages of a project (e).g., a comparison between _master_ and _staging_, and a second between _staging_ and _production_)
- A cron periodically reevaluates these comparisons, creating a new snapshot if the state has changed at all.
- A `Stage` (such as "production") can have a `DeployStrategy` for automatically triggering releases. Currently only the "github pull request" provider is implemented. When defined, a deploy strategy will automatically start a release (e.g., by opening a pull request) when a diff exceeds a certain threshold.
- `DeployBlock`s indicate that a project _should not_ be released. In addition to appearing on dashboards, any unresolved blocks will prevent new releases from being automated.

## TO DO

- ~~Support hokusai~~
- ~~Better visual~~
- ~~Allow SSH keys to be configured for each org or project (probably like `git config --local core.sshCommand "ssh -i ~/.ssh/some_key_file"`...). (Maybe not necessary given github/heroku tokens in https URLs)~~
- ~~sanitize URLs with tokens/credentials in them~~
- ~~instead of including tokens in each git URL, define "profiles" associated with each organization and project~~
- Experiment with programmatic git/hokusai access instead of shelling out
- button to refresh project on-demand
- ~~Fix ugly AWS credentials -> hokusai flow~~
- ~~Make errors [when refreshing projects] visible and avoid short-circuiting entire cron~~
- ~~Make sorting and classifying of projects more sophisticated (penalize staleness and number of contributors and not just number of commits)~~
- ~~Add tags to projects and enable filtering dashboard/list view by them~~
