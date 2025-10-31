class RegistrationsController < ApplicationController
    def new
        @user = User.new
        @user.role = 'buyer' # За замовчуванням реєструємось як покупець
      end

    def create
        @user = User.new(user_params)
        @user.role = 'buyer' # Закріплюємо роль покупця
        if @user.save
            session[:user_id] = @user.id
            redirect_to root_path, notice: "Успішна реєстрація!"
          else
            render :new, status: :unprocessable_entity
          end
      end

      private
      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
end