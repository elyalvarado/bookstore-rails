require "rails_helper"

RSpec.describe "Publishing Houses", type: :request do
  let(:valid_attributes) {
    FactoryBot.attributes_for(:publishing_house)
  }

  let(:invalid_attributes) {
    FactoryBot.attributes_for(:publishing_house, name: nil)
  }

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
  end

  describe "POST /publishing_houses" do
    context "with valid params" do
      it "creates a new PublishingHouse" do
        expect {
          post publishing_houses_path, params: {publishing_house: valid_attributes}
        }.to change(PublishingHouse, :count).by(1)
      end

      it "renders a JSON response with the new publishing_house" do
        post publishing_houses_path, params: {publishing_house: valid_attributes}
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match("application/json")
        expect(response.location).to eq(publishing_house_url(PublishingHouse.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new publishing_house" do
        post publishing_houses_path, params: {publishing_house: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match("application/json")
      end
    end
  end

  describe "PUT /publishing_houses/:id" do
    let(:publishing_house) { FactoryBot.create(:publishing_house) }
    context "with valid params" do
      let(:new_attributes) {
        {name: "New Name"}
      }

      it "updates the requested publishing_house" do
        put publishing_house_path(publishing_house), params: {publishing_house: new_attributes}
        publishing_house.reload
        expect(publishing_house.name).to eq("New Name")
      end

      it "renders a JSON response with the publishing_house" do
        put publishing_house_path(publishing_house), params: {publishing_house: new_attributes}
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match("application/json")
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the publishing_house" do
        put publishing_house_path(publishing_house), params: {publishing_house: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match("application/json")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested publishing_house" do
      publishing_house = FactoryBot.create(:publishing_house)
      expect {
        delete publishing_house_path(publishing_house)
      }.to change(PublishingHouse, :count).by(-1)
    end
  end
end
