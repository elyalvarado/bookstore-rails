require "rails_helper"

RSpec.describe "Books", type: :request do
  let(:valid_attributes) {
    author = FactoryBot.create(:author)
    book = FactoryBot.build(:book, author: author, publisher: author)
    ActiveModelSerializers::SerializableResource.new(book, adapter: :json_api).as_json
  }

  let(:invalid_attributes) {
    book = FactoryBot.build(:book, title: nil)
    ActiveModelSerializers::SerializableResource.new(book, adapter: :json_api).as_json
  }

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

  describe "GET /books" do
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

  describe "POST /books" do
    context "with valid params" do
      it "creates a new Book" do
        expect {
          post books_path, params: valid_attributes
        }.to change(Book, :count).by(1)
      end

      it "renders a JSON response with the new book" do
        post books_path, params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match("application/json")
        expect(response.location).to eq(book_url(Book.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new book" do
        post books_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match("application/json")
      end
    end
  end

  describe "PUT /books/:id" do
    let(:book) { FactoryBot.create(:book) }

    context "with valid params" do
      let(:new_attributes) {
        valid_attributes[:data][:attributes][:title] = "New Title"
        valid_attributes
      }

      it "updates the requested book" do
        put book_path(book), params: new_attributes
        book.reload
        expect(book.title).to eq("New Title")
      end

      it "renders a JSON response with the book" do
        put book_path(book), params: new_attributes
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match("application/json")
      end

      it "the JSON response matches the book schema" do
        put book_path(book), params: new_attributes
        expect(response).to have_http_status(:ok)
        expect(response.body).to match_schema(:book)
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the book" do
        put book_path(book), params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match("application/json")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested book" do
      book = FactoryBot.create(:book)
      expect {
        delete book_path(book)
      }.to change(Book, :count).by(-1)
    end
  end
end
