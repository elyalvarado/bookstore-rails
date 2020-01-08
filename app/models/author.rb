class Author < ApplicationRecord
  SELF_PUBLISHING_DISCOUNT = 10
  has_many :books, dependent: :destroy
  has_many :published, as: :publisher, foreign_key: :publisher_id, class_name: "Book", dependent: :destroy

  validates :name, presence: true

  def discount
    SELF_PUBLISHING_DISCOUNT
  end
end
