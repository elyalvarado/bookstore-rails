require "rails_helper"

RSpec.describe Author, type: :model do
  it "validates that name is present" do
    author = FactoryBot.build(:author, name: nil)
    expect(author).to be_invalid
  end

  it "validates that name is not blank" do
    author = FactoryBot.build(:author, name: "")
    expect(author).to be_invalid
  end
end
