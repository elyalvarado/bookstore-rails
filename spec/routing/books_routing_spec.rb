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

    it "does not route to #create" do
      expect(post: "/books").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/books/1").not_to be_routable
    end

    it "does not routes to #update via PATCH" do
      expect(patch: "/books/1").not_to be_routable
    end

    it "does not routes to #destroy" do
      expect(delete: "/books/1").not_to be_routable
    end
  end
end
