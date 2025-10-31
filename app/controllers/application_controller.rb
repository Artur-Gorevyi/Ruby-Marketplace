class ApplicationController < ActionController::Base

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def require_user_logged_in
    unless current_user
      redirect_to login_path, alert: "Будь ласка, увійдіть в систему"
    end
  end

  def require_buyer
    require_user_logged_in
    unless current_user&.buyer?
      redirect_to root_path, alert: "Доступно тільки для покупців"
    end
  end

  def require_seller
    require_user_logged_in
    unless current_user&.seller?
      redirect_to root_path, alert: "Доступно тільки для продавців"
    end
  end
end
