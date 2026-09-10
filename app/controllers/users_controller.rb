class UsersController < ApplicationController
  # Форма регистрации
  def new
    redirect_to books_path if logged_in?
    @user = User.new
  end

  # Создание пользователя и автоматический вход после регистрации
  def create
    @user = User.new(user_params)

    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to books_path, notice: I18n.t("flash.signup_success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Strong Parameters: разрешаем только те поля, которые пользователь имеет право задавать
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
