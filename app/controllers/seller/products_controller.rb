class Seller::ProductsController < ApplicationController
  layout 'seller'
  before_action :require_seller
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = current_user.products.order(created_at: :desc)
  end

  def show
  end

  def new
    @product = current_user.products.build
  end

  def create
    @product = current_user.products.build(product_params)

    if @product.save
      redirect_to seller_products_path, notice: "Товар успішно створено!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to seller_products_path, notice: "Товар успішно оновлено!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to seller_products_path, notice: "Товар видалено!"
  end

  private

  def set_product
    @product = current_user.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:short_description, :description, :price, :category, :color, photos: [])
  end
end

