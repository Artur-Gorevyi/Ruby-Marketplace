class User < ApplicationRecord
    has_secure_password
  
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :role, presence: true, inclusion: { in: %w[buyer seller] }
    validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  
    enum :role, { buyer: 'buyer', seller: 'seller' }
    
    # Зв'язок для продавців
    has_many :products, class_name: 'Product', foreign_key: 'seller_id', dependent: :destroy
  end