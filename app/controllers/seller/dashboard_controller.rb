class Seller::DashboardController < ApplicationController
  layout 'seller'
  before_action :require_seller

  def index
    # Головна сторінка кабінету продавця
  end
end

