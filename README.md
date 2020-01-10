# Awesome Bookstore

This App is the Backend for a bookstore managed from GitHub, completely written in ruby on rails version 6.
The companion frontend app written in ember is also available at
[https://github.com/elyalvarado/bookstore-ember](https://github.com/elyalvarado/bookstore-ember).

## Setting up the Development Environment

### Requirements
In order to run the app you'll need the following:

* Ruby version: 2.6.5 (the project contains a .ruby-version file, so if using a ruby version manager like rvm or rbenv 
  it should be automatically detected)
* PostgreSQL database (tested in 12.1)

### Configuring the app for development

#### Cloning the repo and installing dependencies
To clone the repo and install the dependencies execute the following commands:

```shell script
git clone https://github.com/elyalvarado/bookstore-rails.git
cd bookstore-rails
bundle install
```

#### Configuring the required credentials
The app uses the new (since 5.2) credentials feature which allows saving all required secrets in and encrypted file.
The project comes with a sample `config/credentials.yml.sample` file that you can use to create your own.

In order to create an encrypted credentials file and its corresponding `master.key` file run the following commands:
```shell script
# Note: the following command uses vim as editor, you can change it according to your own preferences
EDITOR=vim bundle exec rails credentials:edit
```

Edit it to match the contents of the config/credentials.yml.sample file:
```yaml
secret_key_base: YOUROWNSECRETKEYBASE # generate a new one using: bundle exec rails secret

# The information for the repository where the authors are going to be managed
authors_github:
  repo: username/repo
  # See: https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line
  token: PERSONALACCESSTOKENFORGITHUB 
  # See: https://developer.github.com/webhooks/securing/
  webhook_key: WEBHOOKKEYFORGITHUB 

bugsnag_api_key: OPTIONALBUGSNAGAPIKEY # Key for the error reporting service: https://bugsnag.com
skylight_authentication: OPTIONALSKYLIGHTAUTHTOKEN # Token for the App Monitoring Service: https://skylight.io
```

*Notes:*
* The personal access token for GitHub requires the repo permissions
* When configuring the GitHub webhook select *let me select individual events* and select only *issues*.
* When configuring the webhook for development, point to an address reachable from the Internet to receive the events. 
  Check the [setting up ngrok section](#setting-up-ngrok) to see how to do it.
* See more about bugsnag and skylight in the [instrumentation section of the docs](#instrumentation-and-monitoring)
* If you want to deploy to production you can either copy the `config/master.key` file to your productions server, or set 
  the `RAILS_MASTER_KEY` enviroment variable with the contents of it

#### Database creation

To setup the database run the following command in the rails root:

```shell script
bundle exec rails db:create
bundle exec rails db:schema:load
```

#### Loading the sample dataset
The app comes with a sample dataset of book, authors and publishers. To load it run the following command:

```shell script
bundle exec rails db:seed
```

#### Syncing with GitHub
The authors are managed in the GitHub repo configured in credentials. In order to sync the initial data with the chosen
repo and create the issues for the existing authors a rake task is provided.

This task does the following:
- Creates issues for authors that don't have a github issue number in the model (and updates their github issue number)
- Updates existing authors with github issue numbers from the github issue info (only if there were modifications)
- Deletes authors with github issue numbers if the github issue doesn't exist anymore
- Creates authors in the database for github issues that don't have a matching author (and creates a self-published book for the author)

To run the task execute the following command (this requires that the 
[credentials are properly configured](Configuring the required credentials):

```shell script
bundle exec rake bookstore:sync_with_github
```

|Note: This task is idempotent, can be run multiple times and will sync the github repo and the database|
|---|

#### Running the test suite
The app ships with an extensive suite of tests. To run them use the following command:

```shell script
bundle exec rake # or bundle exec rspec, or bundle exec rails spec
```

After running the tests a coverage report will be generated on the `coverage/index.html` file. Open it in a browser to 
check the code coverage of the test suite.

#### Running the Server
Once everything is setup you can run the rails server by executing the following command:
```shell script
bundle exec rails server
```

#### Setting up Ngrok
Normally developer machines are not reachable from the internet, but you can use a service like [ngrok](https://ngrok.com)
to proxy connections from an externally available address to your localhost.

In order to setup ngrok, [download and follow the instructions in the official docs](https://ngrok.com/download). Once 
ngrok is setup run the following command to expose your rails development server to the internet:

```shell script
ngrok http 3000
```

Once ngrok runs, take note of the URL it was assigned and make sure to edit your GitHub webhook to point to it.

## Instrumentation and Monitoring

### SimpleCov
The app includes the SimpleCov gem to automatically generate code coverage reports anytime the specs are run.

### Codecov.io
The codecove gem for sending the code coverage reportes generated by SimpleCov to CodeCov.io is also included. To send 
the reports set the `CI` environment variable to `true` and the `CODECOV_TOKEN` environment variable to the repository
upload token. [Codecove.io](https://codecove.io) is an online service that allows to track code coverage metrics across
time.

### Brakeman
In the development environment the app includes brakeman, a static security analyzer for rails apps that can be used
to check for common security issues in the app. To run it execute:

```shell script
bundle exec brakeman
```

### standardRB
[standardRB](https://github.com/testdouble/standard) is a ruby style guide, linter and formatter with a set of opinionated
rules to ensure consistent code formatting of ruby code. To run it execute:

```shell script
bundle exec standardrb
```

### GitHub Actions
The project includes a GitHub action workflow configured that runs the tests, send the coverage report to codecov.io,
executes brakeman, and checks the code with standardrb; all of it on every push and pull request done to the repository.
The workflow configuration file can be found at `.github/workflows/main.yml`. 

### Bugsnag
The app includes the bugsnag gem, to automatically submit unhandled exceptions to Bugsnag. Bugsnag is an error and 
stability monitoring service that centralizes unhandled exceptions in the app in a dashboard. Learn more about bugsnag 
in [their site](https://bugsnag.com)

### Skylight.io
The app includes the agent for the skylight monitoring service. Skylight is an application monitoring service specialized 
in rails apps with an agent written in rust that makes it really fast and with a very low overhead. Learn more about 
skylight in [their site](https://skylight.io)

