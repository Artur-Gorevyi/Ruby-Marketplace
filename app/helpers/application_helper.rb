module ApplicationHelper
  # Перевіряє чи товар вже є в кошику
  # Працює для зареєстрованих користувачів (БД) та гостей (session)
  def product_in_cart?(product)
    if current_user
      current_user.cart_items.exists?(product: product)
    else
      # Для гостей перевіряємо session
      session[:cart]&.key?(product.id.to_s) || false
    end
  end

  # Перевіряє чи користувач/гість може купити товар
  # Покупець може купити будь-який товар
  # Продавець може купити тільки товари інших продавців, але не свої
  # Гість може купити будь-який товар (якщо не продавець)
  def can_buy_product?(product)
    # Гість може купити будь-який товар
    return true unless current_user
    
    # Зареєстрований користувач не може купити свій товар
    return false if current_user == product.seller
    
    true
  end

  # Отримати кількість товару в кошику
  def cart_quantity_for_product(product)
    if current_user
      cart_item = current_user.cart_items.find_by(product: product)
      cart_item&.quantity || 0
    else
      session[:cart]&.dig(product.id.to_s).to_i || 0
    end
  end

  # Отримати загальну кількість товарів у кошику
  def cart_items_count
    if current_user
      current_user.cart_items.sum(:quantity)
    else
      session[:cart]&.values&.sum || 0
    end
  end
end
