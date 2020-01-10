namespace :bookstore do
  desc "Syncs the Authors with GitHub. Create authors not yet synced both ways, deletes removed ones and updates existing ones"
  task sync_with_github: :environment do
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = :info

    @repo = Rails.application.credentials.authors_github[:repo]
    @token = Rails.application.credentials.authors_github[:token]
    sync_service = GithubSyncService.new(repo: @repo, token: @token)
    sync_service.sync
  rescue KeyError => _
    Rails.logger.error("To sync with github you need to define AUTHORS_GITHUB_REPO and AUTHORS_GITHUB_TOKEN as environment variables")
  rescue => err
    Rails.logger.error("There was an error: #{err}")
  end
end
