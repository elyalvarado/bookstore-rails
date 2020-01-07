require "rails_helper"

RSpec.describe "Publishing Houses", type: :request do
  let(:valid_attributes) {
    publishing_house = FactoryBot.build(:publishing_house)
    ActiveModelSerializers::SerializableResource.new(publishing_house, adapter: :json_api).as_json
  }

  let(:invalid_attributes) {
    publishing_house = FactoryBot.build(:publishing_house, name: nil)
    ActiveModelSerializers::SerializableResource.new(publishing_house, adapter: :json_api).as_json
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

    it "the response matches the JSON schema for publishing house" do
      publishing_house = FactoryBot.create(:publishing_house)
      get publishing_house_path(publishing_house)
      expect(response.body).to match_schema(:publishing_house)
    end
  end

  describe "POST /publishing_houses" do
    context "with valid params" do
      it "creates a new PublishingHouse" do
        expect {
          post publishing_houses_path, params: valid_attributes
        }.to change(PublishingHouse, :count).by(1)
      end

      it "renders a JSON response with the new publishing_house" do
        post publishing_houses_path, params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match("application/json")
        expect(response.location).to eq(publishing_house_url(PublishingHouse.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new publishing_house" do
        post publishing_houses_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match("application/json")
      end
    end
  end

  describe "PUT /publishing_houses/:id" do
    let(:publishing_house) { FactoryBot.create(:publishing_house) }
    context "with valid params" do
      let(:new_attributes) {
        valid_attributes[:data][:attributes][:name] = "New Name"
        valid_attributes
      }

      it "updates the requested publishing_house" do
        put publishing_house_path(publishing_house), params: new_attributes
        publishing_house.reload
        expect(publishing_house.name).to eq("New Name")
      end

      it "renders a JSON response with the publishing_house" do
        put publishing_house_path(publishing_house), params: new_attributes
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match("application/json")
      end

      it "the response matches the publishing house schema" do
        put publishing_house_path(publishing_house), params: new_attributes
        expect(response).to have_http_status(:ok)
        expect(response.body).to match_schema(:publishing_house)
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the publishing_house" do
        put publishing_house_path(publishing_house), params: invalid_attributes
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
