class ApplicationController < ActionController::Base
  # Разрешаем только современные браузеры (поддержка webp, import maps, CSS nesting, :has)
  allow_browser versions: :modern

  before_action :set_locale

  # Делаем методы доступными во views
  helper_method :current_user, :logged_in?

  # Стандартная ошибка "запись не найдена": для API — JSON, для браузера — редирект с flash
  rescue_from ActiveRecord::RecordNotFound do |exception|
    logger.warn "RecordNotFound: #{exception.message}"

    if api_request?
      render json: { error: I18n.t("flash.record_not_found"), status: :not_found }, status: :not_found
    else
      redirect_to root_path, alert: I18n.t("flash.record_not_found")
    end
  end

  # Перехват несуществующих маршрутов (match "*path" в routes.rb)
  rescue_from ActionController::RoutingError do |exception|
    logger.error "Routing error occurred: #{exception.message}"

    if api_request?
      render json: { error: I18n.t("api.no_route"), status: :no_route }, status: :not_found
    else
      redirect_to root_path, alert: I18n.t("flash.not_found")
    end
  end

  def catch_404
    raise ActionController::RoutingError.new(params[:path])
  end

  private

  # ---------- Локализация ----------

  # Берём локаль из URL (/en/..., /ru/...), иначе используем локаль по умолчанию
  def set_locale
    requested = params[:locale].to_s
    I18n.locale = I18n.available_locales.map(&:to_s).include?(requested) ? requested : I18n.default_locale
  end

  # Все генерируемые ссылки автоматически получают текущую локаль.
  # Для локали по умолчанию сегмент опускается: /books вместо /ru/books
  def default_url_options
    { locale: (I18n.locale == I18n.default_locale ? nil : I18n.locale) }
  end

  # ---------- Аутентификация ----------

  # Текущий пользователь, определяемый по session[:user_id]; результат кешируется в @current_user
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = session[:user_id] && User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  # before_action для защиты маршрутов, требующих входа в систему
  def authorize
    return if logged_in?

    session[:return_to] = request.fullpath if request.get?
    redirect_to login_path, alert: I18n.t("flash.unauthorized")
  end

  def api_request?
    request.path.start_with?("/api/") || request.format.json?
  end
end
