class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  validates :quantity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 999 }
  validates :user_id, uniqueness: { scope: :product_id, message: "Товар вже є в кошику" }
end
