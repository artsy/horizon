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

Local development depends on a `.env.shared` file (sourced from S3) and a `.env` file for any overrides or additions. The setup script will initialize these in addition to installing prerequisites and generating seed data:

    ./bin/setup

Then, to develop with docker:

    hokusai dev run 'bundle exec rake db:prepare db:seed:replant'
    hokusai dev start

Or on localhost:

    yarn install
    foreman run bundle exec rails server

    # run the webpack-dev-server in a seperate terminal window for hot reloading and faster compilation:
    ./bin/webpack-dev-server

The UI can then be found at http://localhost:3000.

## Design

- `Organization`s have many `Project`s
- Each `Project` has an associated list of `Stage`s, with their order determined by `Stage#position` (e.g., _master_, _staging_, and _production_)
- `Stage`s must describe how to get information about their current state. This takes the form of a `#git_remote` (e.g., referring to Github or Heroku), optional `#branch` name (default: _master_), optional `#hokusai` environment (e.g., _staging_ or _production_), or `#tag_pattern` (e.g., _release-\*_). The [`releasecop` gem](https://github.com/joeyAghion/releasecop) is used internally to determine stage diffs, so see that project for more detail.
- `Stage`s can optionally be associated with a `Profile` that stores credentials for accessing git providers or AWS.
- `Snapshot`s capture the complete state of a project's stages at a point in time. Each `Snapshot` has associated `Comparison`s between the consecutive stages of a project (e).g., a comparison between _master_ and _staging_, and a second between _staging_ and _production_)
- A cron periodically reevaluates these comparisons, creating a new snapshot if the state has changed at all.
- A `Stage` (such as "production") can have a `DeployStrategy` for automatically triggering releases. Currently only the "github pull request" provider is implemented. When defined, a deploy strategy will automatically start a release (e.g., by opening a pull request) when a diff exceeds a certain threshold.
- `DeployBlock`s indicate that a project _should not_ be released. In addition to appearing on dashboards, any unresolved blocks will prevent new releases from being automated.

## Adding a new project

* Navigate to the [new project form](https://releases.artsy.net/admin/projects/new) and specify the name, description, and any tags (often _teams_) associated with the project.
* Follow the _stages_ link and click to create a new stage:
  * Choose a "profile" granting access to the repository or deployment (e.g., `github...`)
  * Enter a name, usually `master` to start
  * Enter a git remote (e.g., `https://github.com/artsy/delta.git`)
  * Enter a tag pattern, branch, or hokusai environment associated with the deployment. For "master," these are usually blank.
* Create additional stages for `staging` (usually specifying the `staging` hokusai environment), and `production` (usually specifying the `production` hokusai environment), if applicable.
* After defining the `production` stage, follow the link to create a new _deploy strategy_.
  * Choose `github pull request` as the provider
  * Choose a profile granting necessary access (usually `github...`)
  * Check the _Automatic_ box so that new release pull requests are opened automatically upon changes being pushed to staging.
  * Provide arguments specifying the relevant branches (usually `{"base":"release","head":"staging"}`)
    * `base` is the _branch name_ that this deploy PR will merge _onto_.
    * `head` is the _horizon stage name_ that this deploy PR will start from.
* To _merge_ release pull requests automatically, specify the additional `merge_after` (in seconds) and--for an optional notification--`slack_webhook_url` (from [Horizon's slack settings](https://api.slack.com/apps/A0188C16QSZ/incoming-webhooks)). E.g.:

```JSON
{
  "base": "release",
  "head": "staging",
  "merge_after": 86400,
  "slack_webhook_url":"https://hooks.slack.com/services/T.../B.../Q..."
}
```

## Adding a "deploy block"

* Navigate to the [new deploy block form](https://releases.artsy.net/admin/deploy_blocks/new).
* Choose a project and describe the reason for blocking deploys. Leave "resolved at" blank.
* While the block is unresolved, Horizon will _not_ open new release pull requests or merge existing ones, but manual merges or deploys are still possible. CircleCI release workflows can use the `block` step defined in the [artsy/release](https://github.com/artsy/orbs/blob/master/src/release/release.yml) orb to short-circuit release builds.
* Once resolved, click _edit_ in the [list of deploy blocks](https://releases-staging.artsy.net/admin/deploy_blocks) and specify a "resolved at" time.

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
