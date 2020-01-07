require "rails_helper"

RSpec.describe Book, type: :model do
  context "Validations" do
    it "validates the author presence" do
      book = FactoryBot.build(:book, author: nil)
      expect(book).to be_invalid
    end

    it "validates the publisher presence" do
      book = FactoryBot.build(:book, publisher: nil)
      expect(book).to be_invalid
    end

    it "validates the title is present" do
      book = FactoryBot.build(:book, title: nil)
      expect(book).to be_invalid
    end

    it "validates the title is not blank" do
      book = FactoryBot.build(:book, title: "")
      expect(book).to be_invalid
    end

    it "validates the price is present" do
      book = FactoryBot.build(:book, price: nil)
      expect(book).to be_invalid
    end

    it "validates the price is numeric" do
      book = FactoryBot.build(:book, price: "invalid")
      expect(book).to be_invalid
    end

    it "validates the price is positive" do
      book = FactoryBot.build(:book, price: -1)
      expect(book).to be_invalid
    end
  end
end
