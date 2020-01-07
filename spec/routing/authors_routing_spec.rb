require "rails_helper"

RSpec.describe AuthorsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/authors").to route_to("authors#index")
      expect(get: authors_path).to route_to("authors#index")
    end

    it "routes to #show" do
      expect(get: "/authors/1").to route_to("authors#show", id: "1")
      expect(get: author_path(1)).to route_to("authors#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/authors").to route_to("authors#create")
      expect(post: authors_path).to route_to("authors#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/authors/1").to route_to("authors#update", id: "1")
      expect(put: author_path(1)).to route_to("authors#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/authors/1").to route_to("authors#update", id: "1")
      expect(patch: author_path(1)).to route_to("authors#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/authors/1").to route_to("authors#destroy", id: "1")
      expect(delete: author_path(1)).to route_to("authors#destroy", id: "1")
    end
  end
end
