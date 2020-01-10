require "rails_helper"

RSpec.describe GithubSyncJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it "queues the job" do
    expect {
      described_class.perform_later("X")
    }.to have_enqueued_job(described_class).with("X").on_queue("default")
  end

  it "calls GithubSyncService#sync_from_event with the received" do
    payload = {"test": "X"}
    mock_service = double("GithubSyncService")
    allow(Rails.application.credentials).to receive(:authors_github).and_return(
      {
        repo: "test/repo",
        token: "TOKEN",
      }
    )

    expect(GithubSyncService).to receive(:new)
      .with(repo: "test/repo", token: "TOKEN")
      .and_return(mock_service)
    expect(mock_service).to receive(:sync_from_event).with(payload)

    perform_enqueued_jobs { described_class.perform_later(payload) }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
