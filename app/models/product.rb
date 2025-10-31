class Product < ApplicationRecord
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  
  # Active Storage для фото (до 4 фото)
  has_many_attached :photos
  
  # Валідації
  validates :short_description, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validate :photos_presence
  validate :photos_limit
  
  private
  
  def photos_presence
    if photos.blank? && new_record?
      errors.add(:photos, "Необхідно додати хоча б одне фото")
    end
  end
  
  def photos_limit
    if photos.attached? && photos.count > 4
      errors.add(:photos, "Можна додати максимум 4 фото")
    end
  end
end
