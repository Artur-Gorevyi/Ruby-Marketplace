class CartController < ApplicationController
  before_action :check_can_buy_product, only: [:add]
  
  def show
    if current_user
      # Зареєстрований користувач - з БД
      @cart_items = load_cart_items_from_db
    else
      # Гість - з session
      @cart_items = load_cart_items_from_session
    end
    
    @grouped_by_seller = @cart_items.group_by { |item| item[:product].seller }
    @total_price = @cart_items.sum { |item| item[:product].price * item[:quantity] }
    @exceeds_stock_for_item = {} # Ініціалізуємо для view
  end
  
  def add
    @product = Product.find(params[:product_id])
    
    # Перевірка наявності товару на складі
    if @product.stock_quantity.to_i <= 0
      redirect_to request.referer || products_path, alert: "Товар відсутній на складі"
      return
    end
    
    if current_user
      # Зареєстрований користувач - зберігаємо в БД
      add_to_db_cart(@product)
    else
      # Гість - зберігаємо в session
      add_to_session_cart(@product)
    end
  end
  
  def remove
    @product = Product.find(params[:product_id])
    
    if current_user
      # Зареєстрований користувач
      cart_item = current_user.cart_items.find_by(product: @product)
      if cart_item
        cart_item.destroy
        respond_to do |format|
          format.html { redirect_to request.referer || cart_path, notice: "Товар видалено з кошика" }
          format.turbo_stream
        end
      else
        redirect_to request.referer || cart_path, alert: "Товар не знайдено в кошику"
      end
    else
      # Гість - видаляємо з session
      session[:cart] ||= {}
      if session[:cart].key?(@product.id.to_s)
        session[:cart].delete(@product.id.to_s)
        session[:cart] = nil if session[:cart].empty?
        respond_to do |format|
          format.html { redirect_to request.referer || cart_path, notice: "Товар видалено з кошика" }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("cart-form-#{@product.id}", partial: "cart/button", locals: { product: @product }) }
        end
      else
        redirect_to request.referer || cart_path, alert: "Товар не знайдено в кошику"
      end
    end
  end
  
  def update
    requested_quantity = params[:quantity].to_i
    quantity = requested_quantity
    
    # Перевірка мінімуму
    quantity = 1 if quantity < 1
    
    if current_user
      # Зареєстрований користувач - оновлюємо в БД
      @cart_item = current_user.cart_items.includes(:product, product: :seller).find(params[:id])
      
      # Перевірка наявності товару на складі
      available_stock = @cart_item.product.stock_quantity.to_i
      if available_stock <= 0
        redirect_to cart_path, alert: "Товар відсутній на складі"
        return
      end
      
      # Зберігаємо інформацію про те, чи спробували встановити більше ніж на складі
      @exceeds_stock = requested_quantity > available_stock
      @exceeds_stock_for_item = { @cart_item.id => @exceeds_stock }
      
      @cart_item.quantity = quantity
      
      if @cart_item.save
        # Перезавантажуємо cart_items для підрахунку сум
        @cart_items = load_cart_items_from_db
        @seller = @cart_item.product.seller
        @seller_items = @cart_items.select { |item| item[:product].seller == @seller }
        @seller_total = @seller_items.sum { |item| item[:product].price * item[:quantity] }
        @total_price = @cart_items.sum { |item| item[:product].price * item[:quantity] }
        
        respond_to do |format|
          format.html { redirect_to cart_path, notice: "Кількість оновлено" }
          format.turbo_stream
        end
      else
        redirect_to cart_path, alert: @cart_item.errors.full_messages.join(", ")
      end
    else
      # Гість - оновлюємо в session
      product_id = params[:id].to_i
      product = Product.find_by(id: product_id)
      
      unless product
        redirect_to cart_path, alert: "Товар не знайдено"
        return
      end
      
      # Перевірка наявності товару на складі
      available_stock = product.stock_quantity.to_i
      if available_stock <= 0
        redirect_to cart_path, alert: "Товар відсутній на складі"
        return
      end
      
      exceeds = requested_quantity > available_stock
      @exceeds_stock_for_item = { product_id => exceeds }
      
      session[:cart] ||= {}
      session[:cart][product_id.to_s] = quantity
      
      @cart_items = load_cart_items_from_session
      @seller = product.seller
      @seller_items = @cart_items.select { |item| item[:product].seller == @seller }
      @seller_total = @seller_items.sum { |item| item[:product].price * item[:quantity] }
      @total_price = @cart_items.sum { |item| item[:product].price * item[:quantity] }
      
      # Створюємо хеш для turbo_stream
      @cart_item = {
        id: product_id,
        product: product,
        quantity: quantity
      }
      
      respond_to do |format|
        format.html { redirect_to cart_path, notice: "Кількість оновлено" }
        format.turbo_stream
      end
    end
  end
  
  def destroy
    if current_user
      cart_item = current_user.cart_items.find(params[:id])
      cart_item.destroy
      redirect_to cart_path, notice: "Товар видалено з кошика"
    else
      # Гість - видаляємо з session
      session[:cart] ||= {}
      session[:cart].delete(params[:id].to_s)
      session[:cart] = nil if session[:cart].empty?
      redirect_to cart_path, notice: "Товар видалено з кошика"
    end
  end
  
  private
  
  def check_can_buy_product
    @product = Product.find(params[:product_id])
    # Для гостей перевіряємо тільки наявність товару на складі
    if current_user && current_user == @product.seller
      redirect_to request.referer || products_path, alert: "Ви не можете купити власний товар"
    end
  end

  # Завантажити кошик з БД (для зареєстрованих користувачів)
  def load_cart_items_from_db
    cart_items = current_user.cart_items.includes(:product, product: :seller)
    cart_items.map do |item|
      {
        id: item.id,
        product: item.product,
        quantity: item.quantity
      }
    end
  end

  # Завантажити кошик з session (для гостей)
  def load_cart_items_from_session
    return [] unless session[:cart] && session[:cart].is_a?(Hash)
    
    items = []
    session[:cart].each do |product_id_str, quantity|
      product = Product.find_by(id: product_id_str.to_i)
      # Пропускаємо товари, які більше не існують
      next unless product
      
      items << {
        id: product.id,
        product: product,
        quantity: quantity.to_i
      }
    end
    
    # Очищаємо session від неіснуючих товарів
    valid_product_ids = items.map { |item| item[:product].id.to_s }
    session[:cart] = session[:cart].slice(*valid_product_ids)
    session[:cart] = nil if session[:cart].empty?
    
    items
  end

  # Додати товар до БД кошика
  def add_to_db_cart(product)
    cart_item = current_user.cart_items.find_or_initialize_by(product: product)
    
    # Якщо товар новий (не в кошику), встановлюємо quantity = 1
    if cart_item.new_record?
      cart_item.quantity = 1
    end
    
    if cart_item.save
      respond_to do |format|
        format.html { redirect_to request.referer || products_path, notice: "Товар додано в кошик" }
        format.turbo_stream
      end
    else
      redirect_to request.referer || products_path, alert: cart_item.errors.full_messages.join(", ")
    end
  end

  # Додати товар до session кошика
  def add_to_session_cart(product)
    session[:cart] ||= {}
    
    # Якщо товар новий (не в кошику), встановлюємо quantity = 1
    unless session[:cart].key?(product.id.to_s)
      session[:cart][product.id.to_s] = 1
    end
    
    respond_to do |format|
      format.html { redirect_to request.referer || products_path, notice: "Товар додано в кошик" }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("cart-form-#{product.id}", partial: "cart/button", locals: { product: product }) }
    end
  end
end

