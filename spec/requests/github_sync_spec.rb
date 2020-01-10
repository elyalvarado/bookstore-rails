require "rails_helper"

RSpec.describe "Github Sync", type: :request do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe "POST /github_sync" do
    context "with valid params" do
      let(:payload_with_known_signature) { {"issue" => {"number": "1"}, "action" => "opened"} }
      let(:known_signature) { "sha1=abb9dec5fe4f2ca362b09ef26b87e1997c4c0596" }
      let(:key_for_testing) { "X" }

      before do
        # mock the configuration to return  known key to get the expected signature
        allow(Rails.application.credentials).to receive(:authors_github).and_return({webhook_key: key_for_testing})
      end

      it "schedules a GitHubSync job" do
        expect {
          post github_sync_path,
            params: payload_with_known_signature,
            headers: {"X-Hub-Signature": known_signature, "X-GitHub-Event": "issues"}
        }.to have_enqueued_job(GithubSyncJob).with(payload_with_known_signature)
      end

      it "responds with no content status" do
        post github_sync_path,
          params: payload_with_known_signature,
          headers: {"X-Hub-Signature": known_signature, "X-GitHub-Event": "issues"}
        expect(response).to have_http_status :no_content
      end

      it "lets the payload action pass through" do
        event_with_action = {"action": "edited"}
        signature_for_event_with_action = "sha1=9a361723b252bc097d58411e431072abf8fef1b6"
        expect {
          post github_sync_path,
            params: event_with_action,
            headers: {"X-Hub-Signature": signature_for_event_with_action, "X-GitHub-Event": "issues"}
        }.to have_enqueued_job(GithubSyncJob).with(event_with_action)
      end
    end

    context "with invalid params" do
      it "ignores github events others than issues" do
        expect {
          post github_sync_path, headers: {"X-Hub-Signature": "ASDFGHJKLASDFGHJKLASDFGHJKL", "X-GitHub-Event": "ping"}
        }.to_not have_enqueued_job(GithubSyncJob)
      end

      it "respond with status no content to event others than issues" do
        post github_sync_path, headers: {"X-Hub-Signature": "ASDFGHJKLASDFGHJKLASDFGHJKL", "X-GitHub-Event": "ping"}
        expect(response).to have_http_status :no_content
      end

      it "ignores request without the github event header" do
        expect {
          post github_sync_path, headers: {"X-Hub-Signature": "ASDFGHJKLASDFGHJKLASDFGHJKL"}
        }.to_not have_enqueued_job(GithubSyncJob)
      end

      it "responds with a forbidden status if no github event is specified" do
        post github_sync_path, headers: {"X-Hub-Signature": "ASDFGHJKLASDFGHJKLASDFGHJKL"}
        expect(response).to have_http_status :forbidden
      end

      it "ignores request without the github signature header" do
        expect {
          post github_sync_path, headers: {"X-GitHub-Event": "issues"}
        }.to_not have_enqueued_job(GithubSyncJob)
      end

      it "responds with a forbidden status if no github signature is specified" do
        post github_sync_path, headers: {"X-GitHub-Event": "issues"}
        expect(response).to have_http_status :forbidden
      end
    end
  end
end
