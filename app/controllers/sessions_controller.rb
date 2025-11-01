class SessionsController < ApplicationController
    def new
      @user = User.new
    end
  
    def create
      @user = User.find_by(email: params[:email])
  
      if @user&.authenticate(params[:password])
        # Зберігаємо session кошик перед логіном
        session_cart = session[:cart]
        
        session[:user_id] = @user.id
        
        # Переносимо товари з session в БД
        transfer_session_cart_to_db(session_cart) if session_cart && session_cart.is_a?(Hash)
        
        redirect_to root_path, notice: "Успішний вхід!"
      else
        flash.now[:alert] = "Неправильний email або пароль"
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session[:user_id] = nil
      redirect_to root_path, notice: "Ви вийшли з системи"
    end
    
    private
    
    def transfer_session_cart_to_db(session_cart)
      return unless session_cart.is_a?(Hash)
      
      session_cart.each do |product_id_str, quantity|
        product = Product.find_by(id: product_id_str.to_i)
        next unless product
        
        # Перевірка: продавець не може купити свій власний товар
        next if @user == product.seller
        
        # Знаходимо або створюємо cart_item
        cart_item = @user.cart_items.find_or_initialize_by(product: product)
        
        if cart_item.new_record?
          # Новий товар - встановлюємо кількість з session
          cart_item.quantity = [quantity.to_i, 1].max
        else
          # Товар вже є в БД - об'єднуємо кількості (додаємо session до БД)
          cart_item.quantity += [quantity.to_i, 1].max
          # Обмежуємо максимумом
          cart_item.quantity = [cart_item.quantity, 999].min
        end
        
        cart_item.save
      end
      
      # Очищаємо session кошик після переносу
      session[:cart] = nil
    end
  end