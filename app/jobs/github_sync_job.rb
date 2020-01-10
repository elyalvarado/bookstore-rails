class GithubSyncJob < ApplicationJob
  queue_as :default

  def perform(event)
    repo = Rails.application.credentials.authors_github[:repo]
    token = Rails.application.credentials.authors_github[:token]
    GithubSyncService.new(repo: repo, token: token).sync_from_event(event)
  end
end
