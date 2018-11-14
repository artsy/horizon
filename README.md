Horizon
===

Visual representations of release pipelines.

Git references (`Stage#git_remote`) should be in this form:

For Heroku:

    https://heroku:<API_TOKEN>@git.heroku.com/<APP_NAME>.git

For github:

    https://<API_TOKEN>@github.com/<USER_OR_ORG>/<REPO>.git

TO DO
---
* Support hokusai
* Visual!
* Allow SSH keys to be configured for each org or project (probably like `git config --local core.sshCommand "ssh -i ~/.ssh/some_key_file"`...). (Maybe not necessary given github/heroku tokens in https URLs)
* sanitize URLs with tokens/credentials in them
* instead of including tokens in each git URL, define "profiles" associated with each organization and project
* Experiment with programmatic git/hokusai access instead of shelling out

