class ProductsController < ApplicationController
  def index
    @products = Product.includes(:seller, photos_attachments: :blob)
                        .order(created_at: :desc)
    
    if params[:search].present?
      search_term = params[:search].strip
      @products = @products.where("short_description ILIKE ? OR description ILIKE ?", 
                                   "%#{search_term}%", "%#{search_term}%")
      @search_term = search_term
    end
  end

  def show
    @product = Product.includes(:seller, photos_attachments: :blob).find(params[:id])
  end
end

