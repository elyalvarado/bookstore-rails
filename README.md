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
