class SessionsController < ApplicationController
  # Форма входа
  def new
    redirect_to books_path if logged_in?
  end

  # Проверка учётных данных и ручное создание сессии
  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      # Защита от фиксации сессии: сбрасываем идентификатор сессии перед входом
      reset_session
      session[:user_id] = user.id

      destination = session.delete(:return_to) || books_path
      redirect_to destination, notice: I18n.t("flash.login_success", email: user.email)
    else
      flash.now[:alert] = I18n.t("flash.login_failed")
      render :new, status: :unprocessable_entity
    end
  end

  # Завершение сессии
  def destroy
    session.delete(:user_id)
    reset_session
    redirect_to login_path, notice: I18n.t("flash.logout_success")
  end
end
