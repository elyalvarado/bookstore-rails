require "rails_helper"

RSpec.describe GithubSyncService, type: :model do
  let(:repo) { "testing/repo" }
  let(:token) { "ASDFGHJKL1234567890" }

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
