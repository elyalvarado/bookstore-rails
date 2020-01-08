# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Deployment Instructions

### Environment variables
| name | description | example value |
|------|-------------|---------------|
|AUTHORS_GITHUB_REPO|The repository where the authors are going to be managed in the following format: `author/repo`| `elyalvarado/bookstore-rails`|
|AUTHORS_GITHUB_TOKEN|The token used to authenticat requests with GitHub (see: [Creating a personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line))| `elyalvarado/bookstore-rails`|
|AUTHORS_GITHUB_WEBHOOK_KEY|Key used to validate the authenticity of the webhook requests coming from GitHub|`9e0738e9af5587f6748...`

### Syncing and populating the GitHub repo issues
In order to create issues for authors already in the database a rake task is provided that can be executed to sync authors with github issues.

This task does the following:
- Creates issues for authors that don't have a github issue number in the model (and updates their github issue number)
- Updates existing authors with github issue numbers from the github issue info (only if there were modifications)
- Deletes authors with github issue numbers if the github issue doesn't exist anymore
- Creates authors in the database for github issues that don't have a matching author (and creates a self-published book for the author)

To run the task:
```shell script
# Set the needed environment variables (see above for description)
export AUTHORS_GITHUB_REPO=username/repo
export AUTHORS_GITHUB_TOKEN=YOURGITHUBPERSONALACCESSTOKEN
bundle exec rake bookstore:sync_with_github
```

| NOTE: This task is safe to run anytime, and will sync authors-issues for all cases where the webhooks didn't run, or for changes while the service was down|
| --- |