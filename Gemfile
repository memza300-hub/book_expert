source "https://rubygems.org"

ruby "~> 3.3.0"

# Основа приложения — Ruby on Rails 8
gem "rails", "~> 8.1.3"

# Конвейер статических файлов Rails 8
gem "propshaft"

# Драйвер PostgreSQL для Active Record
gem "pg", "~> 1.5"

# Веб-сервер Puma
gem "puma", ">= 5.0"

# Загрузка JavaScript-модулей без сборщика (ESM import maps)
gem "importmap-rails"

# Hotwire: Turbo и Stimulus (поставляются с Rails 8 по умолчанию)
gem "turbo-rails"
gem "stimulus-rails"

# Хеширование паролей для has_secure_password
gem "bcrypt", "~> 3.1.7"

# Сериализация моделей в JSON для API (app/serializers/*_serializer.rb)
gem "active_model_serializers", "~> 0.10.14"

# Сброс последовательностей первичных ключей PostgreSQL при загрузке сидов
gem "activerecord-reset-pk-sequence"

# Ограничение частоты запросов к API и форме входа (защита от накрутки оценок и перебора паролей)
gem "rack-attack", "~> 6.7"

# Данные о часовых поясах для Windows и JRuby
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Ускорение загрузки приложения за счёт кеширования
gem "bootsnap", require: false

group :development, :test do
  # Отладчик, встроенный в Ruby 3.x
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :development do
  # Консоль в браузере на страницах ошибок
  gem "web-console"
end

group :development do
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end
