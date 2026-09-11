class ApplicationController < ActionController::Base
  # Р Р°Р·СЂРµС€Р°РµРј С‚РѕР»СЊРєРѕ СЃРѕРІСЂРµРјРµРЅРЅС‹Рµ Р±СЂР°СѓР·РµСЂС‹ (РїРѕРґРґРµСЂР¶РєР° webp, import maps, CSS nesting, :has)
  allow_browser versions: :modern

  before_action :set_locale

  # Р”РµР»Р°РµРј РјРµС‚РѕРґС‹ РґРѕСЃС‚СѓРїРЅС‹РјРё РІРѕ views
  helper_method :current_user, :logged_in?

  # РЎС‚Р°РЅРґР°СЂС‚РЅР°СЏ РѕС€РёР±РєР° "Р·Р°РїРёСЃСЊ РЅРµ РЅР°Р№РґРµРЅР°": РґР»СЏ API вЂ” JSON, РґР»СЏ Р±СЂР°СѓР·РµСЂР° вЂ” СЂРµРґРёСЂРµРєС‚ СЃ flash
  rescue_from ActiveRecord::RecordNotFound do |exception|
    logger.warn "RecordNotFound: #{exception.message}"

    if api_request?
      render json: { error: I18n.t("flash.record_not_found"), status: :not_found }, status: :not_found
    else
      redirect_to root_path, alert: I18n.t("flash.record_not_found")
    end
  end

  # РџРµСЂРµС…РІР°С‚ РЅРµСЃСѓС‰РµСЃС‚РІСѓСЋС‰РёС… РјР°СЂС€СЂСѓС‚РѕРІ (match "*path" РІ routes.rb)
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

  # ---------- Р›РѕРєР°Р»РёР·Р°С†РёСЏ ----------

  # Р‘РµСЂС‘Рј Р»РѕРєР°Р»СЊ РёР· URL (/en/..., /ru/...), РёРЅР°С‡Рµ РёСЃРїРѕР»СЊР·СѓРµРј Р»РѕРєР°Р»СЊ РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ
  def set_locale
    requested = params[:locale].to_s
    I18n.locale = I18n.available_locales.map(&:to_s).include?(requested) ? requested : I18n.default_locale
  end

  # Р’СЃРµ РіРµРЅРµСЂРёСЂСѓРµРјС‹Рµ СЃСЃС‹Р»РєРё Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё РїРѕР»СѓС‡Р°СЋС‚ С‚РµРєСѓС‰СѓСЋ Р»РѕРєР°Р»СЊ.
  # Р”Р»СЏ Р»РѕРєР°Р»Рё РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ СЃРµРіРјРµРЅС‚ РѕРїСѓСЃРєР°РµС‚СЃСЏ: /books РІРјРµСЃС‚Рѕ /ru/books
  def default_url_options
    { locale: (I18n.locale == I18n.default_locale ? nil : I18n.locale) }
  end

  # ---------- РђСѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ ----------

  # РўРµРєСѓС‰РёР№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ, РѕРїСЂРµРґРµР»СЏРµРјС‹Р№ РїРѕ session[:user_id]; СЂРµР·СѓР»СЊС‚Р°С‚ РєРµС€РёСЂСѓРµС‚СЃСЏ РІ @current_user
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = session[:user_id] && User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  # before_action РґР»СЏ Р·Р°С‰РёС‚С‹ РјР°СЂС€СЂСѓС‚РѕРІ, С‚СЂРµР±СѓСЋС‰РёС… РІС…РѕРґР° РІ СЃРёСЃС‚РµРјСѓ
  def authorize
    return if logged_in?

    session[:return_to] = request.fullpath if request.get? || request.head?
    redirect_to login_path, alert: I18n.t("flash.unauthorized")
  end

  def api_request?
    request.path.start_with?("/api/") || request.format.json?
  end
end
