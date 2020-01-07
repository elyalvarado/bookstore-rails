FactoryBot.define do
  factory :book do
    title { "MyString" }
    price { 9.99 }
    author
    association :publisher, factory: :publishing_house
  end
end
