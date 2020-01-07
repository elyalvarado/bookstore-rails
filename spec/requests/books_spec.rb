require "rails_helper"

RSpec.describe "Books", type: :request do
  let(:valid_attributes) {
    author = FactoryBot.create(:author)
    FactoryBot.attributes_with_foreign_keys_for(:book, author: author, publisher: author)
  }

  let(:invalid_attributes) {
    FactoryBot.attributes_for(:book, title: nil)
  }

  describe "GET /books" do
    it "returns a success response" do
      get books_path
      expect(response).to be_successful
    end
  end

  describe "GET /books" do
    it "returns a success response" do
      book = FactoryBot.create(:book)
      get book_path(book)
      expect(response).to be_successful
    end
  end

  describe "POST /books" do
    context "with valid params" do
      it "creates a new Book" do
        expect {
          post books_path, params: {book: valid_attributes}
        }.to change(Book, :count).by(1)
      end

      it "renders a JSON response with the new book" do
        post books_path, params: {book: valid_attributes}
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match("application/json")
        expect(response.location).to eq(book_url(Book.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new book" do
        post books_path, params: {book: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match("application/json")
      end
    end
  end

  describe "PUT /books/:id" do
    let(:book) { FactoryBot.create(:book) }

    context "with valid params" do
      let(:new_attributes) {
        {title: "New Title"}
      }

      it "updates the requested book" do
        put book_path(book), params: {book: new_attributes}
        book.reload
        expect(book.title).to eq("New Title")
      end

      it "renders a JSON response with the book" do
        put book_path(book), params: {book: new_attributes}
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match("application/json")
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the book" do
        put book_path(book), params: {book: invalid_attributes}
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
