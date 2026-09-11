ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Загружать все фикстуры из test/fixtures перед каждым тестом
    fixtures :all

    # Вход пользователя через реальную форму (для интеграционных тестов)
    def log_in_as(user, password: "password")
      post login_path, params: { email: user.email, password: password }
    end
  end
end
