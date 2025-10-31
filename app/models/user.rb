class User < ApplicationRecord
    has_secure_password
  
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :role, presence: true, inclusion: { in: %w[buyer seller] }
    validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  
    enum :role, { buyer: 'buyer', seller: 'seller' }
  end