class Author < ApplicationRecord
  SELF_PUBLISHING_DISCOUNT = 10
  has_many :books
  has_many :published, as: :publisher, foreign_key: :publisher_id, class_name: "Book"

  validates :name, presence: true

  def discount
    SELF_PUBLISHING_DISCOUNT
  end
end
