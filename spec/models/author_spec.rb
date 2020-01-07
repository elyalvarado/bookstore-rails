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

  describe "#discount" do
    it "always returns 10 percent discount for self-published books" do
      author = FactoryBot.build(:author)
      expect(author.discount).to eq(10)
    end
  end
end
