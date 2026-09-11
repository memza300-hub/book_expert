# Rate limiting for BookExpert (gem rack-attack).
#
# Rack::Attack is a Rack middleware: it runs BEFORE the Rails router and controllers,
# so a throttled request never reaches the application code or the database.
#
# Rules:
#   * POST /api/v1/books  - at most 10 evaluations per minute from one IP address
#                           (protects against automated rating stuffing);
#   * GET  /api/v1/books  - at most 30 requests per minute from one IP address;
#   * POST /login         - at most 5 attempts per 20 seconds from one IP address
#                           (protects against password brute force).
#
# Counters live in an in-memory cache. In production they should be moved to
# a shared store (Redis / Solid Cache) so that all Puma workers see the same numbers.

class Rack::Attack
  # Explicit store: the default Rails cache in development is a null store,
  # which would silently disable throttling
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  API_BOOKS_PATH = "/api/v1/books".freeze
  LOGIN_PATH_RE  = %r{\A/(ru/|en/)?login\z}

  # ---------- Throttles ----------

  throttle("api/books/create/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.post? && req.path == API_BOOKS_PATH
  end

  throttle("api/books/index/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.get? && req.path == API_BOOKS_PATH
  end

  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.post? && req.path.match?(LOGIN_PATH_RE)
  end

  # ---------- Response for throttled requests ----------

  self.throttled_responder = lambda do |request|
    match_data  = request.env["rack.attack.match_data"] || {}
    period      = match_data[:period].to_i
    epoch_now   = match_data[:epoch_time].to_i
    retry_after = period.positive? ? period - (epoch_now % period) : 60

    locale  = request.params["locale"].presence_in(%w[ru en]) || I18n.default_locale
    message = I18n.t("api.too_many_requests", seconds: retry_after, locale: locale)

    body = { error: message, status: "too_many_requests", retry_after: retry_after }.to_json

    [
      429,
      {
        "Content-Type" => "application/json; charset=utf-8",
        "Retry-After"  => retry_after.to_s
      },
      [ body ]
    ]
  end
end

# Log every throttled request so that attacks are visible in production logs
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  Rails.logger.warn "[Rack::Attack] throttled #{req.ip} #{req.request_method} #{req.path} (#{req.env['rack.attack.matched']})"
end
