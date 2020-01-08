class AuthorSerializer < ActiveModel::Serializer
  attributes :id, :name, :discount, :bio
  has_many :books
  has_many :published
end
