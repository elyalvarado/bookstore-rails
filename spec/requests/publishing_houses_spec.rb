require "rails_helper"

RSpec.describe "Publishing Houses", type: :request do
  describe "GET /publishing_houses" do
    it "returns a success response" do
      get publishing_houses_path
      expect(response).to be_successful
    end
  end

  describe "GET /publishing_houses/:id" do
    it "returns a success response" do
      publishing_house = FactoryBot.create(:publishing_house)
      get publishing_house_path(publishing_house)
      expect(response).to be_successful
    end

    it "the response matches the JSON schema for publishing house" do
      publishing_house = FactoryBot.create(:publishing_house)
      get publishing_house_path(publishing_house)
      expect(response.body).to match_schema(:publishing_house)
    end
  end
end
