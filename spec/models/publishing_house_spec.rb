require "rails_helper"

RSpec.describe PublishingHouse, type: :model do
  it "validates that name is present" do
    publishing_house = FactoryBot.build(:publishing_house, name: nil)
    expect(publishing_house).to be_invalid
  end

  it "validates that name is not blank" do
    publishing_house = FactoryBot.build(:publishing_house, name: "")
    expect(publishing_house).to be_invalid
  end
end
