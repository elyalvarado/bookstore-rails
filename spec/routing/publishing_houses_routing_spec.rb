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

    it "does not route to #create" do
      expect(post: "/publishing_houses").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/publishing_houses/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/publishing_houses/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/publishing_houses/1").not_to be_routable
    end
  end
end
