class HomeController < ApplicationController
  def index
    # Останні 9 товарів для відображення на головній сторінці
    @latest_products = Product.includes(:seller, photos_attachments: :blob)
                              .order(created_at: :desc)
                              .limit(9)
  end
end
