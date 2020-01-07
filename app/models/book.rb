class Book < ApplicationRecord
  belongs_to :author
  belongs_to :publisher, polymorphic: true

  validates :title, presence: true
  validates :price, numericality: {allow_nil: false, greater_than_or_equal_to: 0}
end
