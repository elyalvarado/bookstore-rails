require "rails_helper"

RSpec.describe GithubSyncService, type: :model do
  let(:repo) { "testing/repo" }
  let(:token) { "ASDFGHJKL1234567890" }

  describe "#sync" do
    before do
      # Stub calls to get issues in the repo
      stub_request(:get, "https://api.github.com/repos/#{repo}/issues")
        .to_return(status: 200, body: "[]", headers: {"Content-Type": "application/json"})

      # Stub calls to create an issue
      stub_request(:post, "https://api.github.com/repos/testing/repo/issues")
        .to_return(status: 200, body: "", headers: {})
    end

    it "uses the provided token for the requests" do
      GithubSyncService.new(repo: repo, token: token).sync

      expect(WebMock).to have_requested(:get, "https://api.github.com/repos/#{repo}/issues")
        .with(
          headers: {'Authorization': "token #{token}"}
        )
    end

    it "creates issues in github for authors that have not been synced" do
      author = FactoryBot.create(:author)
      GithubSyncService.new(repo: repo, token: token).sync

      expect(WebMock).to have_requested(:post, "https://api.github.com/repos/#{repo}/issues")
        .with(
          body: {"labels": [], "title": author.name, "body": author.bio},
          headers: {"Content-Type" => "application/json"}
        )
    end

    it "creates authors for issues that don't have a corresponding author" do
      github_issues_body = File.read("#{Rails.root}/spec/support/api_fixtures/github_issues.json")
      github_issues = JSON.parse(github_issues_body)
      stub_request(:get, "https://api.github.com/repos/#{repo}/issues")
        .to_return(status: 200, body: github_issues_body, headers: {"Content-Type": "application/json"})
      time_now = Time.now
      allow(Time).to receive(:now).and_return(time_now) # Stop time for this test

      expect {
        GithubSyncService.new(repo: repo, token: token).sync
      }.to change { Author.count }.by(github_issues.size)

      github_issues.each do |issue|
        author_for_issue = Author.find_by_gh_issue_number(issue["number"])
        expect(author_for_issue).to_not be_nil
        expect(author_for_issue.gh_issue_number).to eq(issue["number"])
        expect(author_for_issue.name).to eq(issue["title"])
        expect(author_for_issue.bio).to eq(issue["body"])
        expect(author_for_issue.gh_last_sync).to eq(time_now)
      end
    end

    it "for created authors it creates a random self published book" do
      github_issues_body = File.read("#{Rails.root}/spec/support/api_fixtures/github_issues.json")
      github_issues = JSON.parse(github_issues_body)
      stub_request(:get, "https://api.github.com/repos/#{repo}/issues")
        .to_return(status: 200, body: github_issues_body, headers: {"Content-Type": "application/json"})

      expect {
        GithubSyncService.new(repo: repo, token: token).sync
      }.to change { Author.count }.by(github_issues.size)

      github_issues.each do |issue|
        expect(Author.find_by_gh_issue_number(issue["number"]).books.count).to be(1)
      end
    end

    it "deletes authors when their issue doesn't exist" do
      FactoryBot.create(:author, gh_issue_number: 999999)

      expect {
        GithubSyncService.new(repo: repo, token: token).sync
      }.to change { Author.count }.by(-1)
    end

    it "updates authors with the information from the github issue if changed" do
      github_issues_body = File.read("#{Rails.root}/spec/support/api_fixtures/github_issues.json")
      github_issues = JSON.parse(github_issues_body)
      stub_request(:get, "https://api.github.com/repos/#{repo}/issues")
        .to_return(status: 200, body: github_issues_body, headers: {"Content-Type": "application/json"})
      time_now = Time.now
      allow(Time).to receive(:now).and_return(time_now) # Stop time for this test

      github_issues.each do |issue|
        FactoryBot.create(:author, gh_issue_number: issue["number"], name: "SHOULD CHANGE", bio: "SHOULD CHANGE TOO")
      end
      GithubSyncService.new(repo: repo, token: token).sync

      github_issues.each do |issue|
        author_for_issue = Author.find_by_gh_issue_number(issue["number"])
        expect(author_for_issue).to_not be_nil
        expect(author_for_issue.gh_issue_number).to eq(issue["number"])
        expect(author_for_issue.name).to eq(issue["title"])
        expect(author_for_issue.bio).to eq(issue["body"])
        expect(author_for_issue.gh_last_sync).to eq(time_now)
      end
    end
  end

  describe "#sync_from_event" do
    let(:event) {
      {
        "action" => "edited",
        "issue" => {
          "number" => 1,
          "title" => "New Author Name",
          "body" => "New Author Bio",
        },
      }
    }

    it "updates an existing author with book from an edited event" do
      author = FactoryBot.create(:author, gh_issue_number: event["issue"]["number"])

      GithubSyncService.new(repo: repo, token: token).sync_from_event(event)
      author.reload

      expect(author.name).to eq(event["issue"]["title"])
      expect(author.bio).to eq(event["issue"]["body"])
    end

    it "creates a new author with book from an edited event" do
      time_now = Time.now
      allow(Time).to receive(:now).and_return(time_now) # Stop time for this test

      GithubSyncService.new(repo: repo, token: token).sync_from_event(event)
      author = Author.first

      expect(author).to be_truthy
      expect(author.name).to eq(event["issue"]["title"])
      expect(author.bio).to eq(event["issue"]["body"])
      expect(author.gh_issue_number).to eq(event["issue"]["number"])
      expect(author.gh_last_sync).to eq(time_now)
      expect(author.books.size).to eq(1)
    end

    it "creates a new author from an opened event" do
      event["action"] = "opened"
      time_now = Time.now
      allow(Time).to receive(:now).and_return(time_now) # Stop time for this test

      GithubSyncService.new(repo: repo, token: token).sync_from_event(event)
      author = Author.first

      expect(author).to be_truthy
      expect(author.name).to eq(event["issue"]["title"])
      expect(author.bio).to eq(event["issue"]["body"])
      expect(author.gh_issue_number).to eq(event["issue"]["number"])
      expect(author.gh_last_sync).to eq(time_now)
      expect(author.books.size).to eq(1)
    end

    it "updates an existing author from an opened event" do
      event["action"] = "opened"
      time_now = Time.now
      allow(Time).to receive(:now).and_return(time_now) # Stop time for this test
      # This case shouldn't happen unless somebody manually sets in the database a higher issue number than
      # the last one existing in GitHub. However, this is handled by the service
      author = FactoryBot.create(:author, gh_issue_number: event["issue"]["number"])

      GithubSyncService.new(repo: repo, token: token).sync_from_event(event)
      author.reload

      expect(author).to be_truthy
      expect(author.name).to eq(event["issue"]["title"])
      expect(author.bio).to eq(event["issue"]["body"])
      expect(author.gh_issue_number).to eq(event["issue"]["number"])
      expect(author.gh_last_sync).to eq(time_now)
    end

    it "deletes an existing author from deleted event" do
      event["action"] = "deleted"
      FactoryBot.create(:author, gh_issue_number: event["issue"]["number"])

      expect {
        GithubSyncService.new(repo: repo, token: token).sync_from_event(event)
      }.to change { Author.count }.by(-1)
    end

    it "ignores delete event for author that doesn't exist" do
      event["action"] = "deleted"
      expect {
        GithubSyncService.new(repo: repo, token: token).sync_from_event(event)
      }.not_to raise_error
    end
  end
end
