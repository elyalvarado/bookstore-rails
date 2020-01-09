require "rails_helper"

RSpec.describe "Books", type: :request do
  describe "GET /books" do
    it "returns a success response" do
      get books_path
      expect(response).to be_successful
    end

    it "the response body includes the total number of books in the meta total attribute" do
      get books_path
      json = JSON.parse(response.body)
      expect(json["meta"]["total"]).to eq(0)
    end

    it "receives a limit parameter that limits the number of results to return" do
      FactoryBot.create_list(:book, 2)
      get books_path, params: {limit: 1}
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
    end
  end

  describe "GET /books/:id" do
    it "returns a success response" do
      book = FactoryBot.create(:book)
      get book_path(book)
      expect(response).to be_successful
    end

    it "the response matches the JSON schema for book" do
      book = FactoryBot.create(:book)
      get book_path(book)
      expect(response.body).to match_schema(:book)
    end
  end
end
