require "rails_helper"

RSpec.describe PublishingHousesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/publishing_houses").to route_to("publishing_houses#index")
      expect(get: publishing_houses_path).to route_to("publishing_houses#index")
    end

    it "routes to #show" do
      expect(get: "/publishing_houses/1").to route_to("publishing_houses#show", id: "1")
      expect(get: publishing_house_path(1)).to route_to("publishing_houses#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/publishing_houses").to route_to("publishing_houses#create")
      expect(post: publishing_houses_path).to route_to("publishing_houses#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/publishing_houses/1").to route_to("publishing_houses#update", id: "1")
      expect(put: publishing_house_path(1)).to route_to("publishing_houses#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/publishing_houses/1").to route_to("publishing_houses#update", id: "1")
      expect(patch: publishing_house_path(1)).to route_to("publishing_houses#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/publishing_houses/1").to route_to("publishing_houses#destroy", id: "1")
      expect(delete: publishing_house_path(1)).to route_to("publishing_houses#destroy", id: "1")
    end
  end
end
