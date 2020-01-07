require "rails_helper"

RSpec.describe BooksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/books").to route_to("books#index")
      expect(get: books_path).to route_to("books#index")
    end

    it "routes to #show" do
      expect(get: "/books/1").to route_to("books#show", id: "1")
      expect(get: book_path(1)).to route_to("books#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/books").to route_to("books#create")
      expect(post: books_path).to route_to("books#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/books/1").to route_to("books#update", id: "1")
      expect(put: book_path(1)).to route_to("books#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/books/1").to route_to("books#update", id: "1")
      expect(patch: book_path(1)).to route_to("books#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/books/1").to route_to("books#destroy", id: "1")
      expect(delete: book_path(1)).to route_to("books#destroy", id: "1")
    end
  end
end
