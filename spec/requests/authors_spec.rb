require "rails_helper"

RSpec.describe "Authors", type: :request do
  let(:valid_attributes) {
    author = FactoryBot.build(:author)
    ActiveModelSerializers::SerializableResource.new(author, adapter: :json_api).as_json
  }

  let(:invalid_attributes) {
    author = FactoryBot.build(:author, name: nil)
    ActiveModelSerializers::SerializableResource.new(author, adapter: :json_api).as_json
  }

  describe "GET /authors" do
    it "returns a success response" do
      get authors_path
      expect(response).to be_successful
    end
  end

  describe "GET /authors/:id" do
    it "returns a success response" do
      author = FactoryBot.create(:author)
      get author_path(author)
      expect(response).to be_successful
    end
  end

  describe "POST /authors" do
    context "with valid params" do
      it "creates a new Author" do
        expect {
          post authors_path, params: valid_attributes
        }.to change(Author, :count).by(1)
      end

      it "renders a JSON response with the new author" do
        post authors_path, params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match("application/json")
        expect(response.location).to eq(author_url(Author.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new author" do
        post authors_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match("application/json")
      end
    end
  end

  describe "PUT /authors/:id" do
    let(:author) { FactoryBot.create(:author) }

    context "with valid params" do
      let(:new_attributes) {
        valid_attributes[:data][:attributes][:name] = "New Name"
        valid_attributes
      }

      it "updates the requested author" do
        put author_path(author), params: new_attributes
        author.reload
        expect(author.name).to eq("New Name")
      end

      it "renders a JSON response with the author" do
        put author_path(author), params: new_attributes
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match("application/json")
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the author" do
        put author_path(author), params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match("application/json")
      end
    end
  end

  describe "DELETE /authors/:id" do
    it "destroys the requested author" do
      author = FactoryBot.create(:author)
      expect {
        delete author_path(author)
      }.to change(Author, :count).by(-1)
    end
  end
end
