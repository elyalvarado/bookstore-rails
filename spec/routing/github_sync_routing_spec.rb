require "rails_helper"

RSpec.describe GithubSyncController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/github_sync").to route_to("github_sync#create")
      expect(post: github_sync_path).to route_to("github_sync#create")
    end
  end
end
