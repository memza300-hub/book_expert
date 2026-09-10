# Настройка интернационализации приложения.
# Доступные локали ограничены русским и английским языками,
# по умолчанию интерфейс отображается на русском.

Rails.application.config.i18n.available_locales = %i[ru en]
Rails.application.config.i18n.default_locale = :ru
Rails.application.config.i18n.fallbacks = [:ru]
