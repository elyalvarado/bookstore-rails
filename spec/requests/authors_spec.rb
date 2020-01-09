require "rails_helper"

RSpec.describe "Authors", type: :request do
  describe "GET /authors" do
    it "returns a success response" do
      get authors_path
      expect(response).to be_successful
    end
  end

  describe "GET /authors/:id" do
    it "returns a success response" do
      author = FactoryBot.create(:author)
      get author_path(author)
      expect(response).to be_successful
    end

    it "the response matches the JSON schema for author" do
      author = FactoryBot.create(:author)
      get author_path(author)
      expect(response.body).to match_schema(:author)
    end
  end
end
