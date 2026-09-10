class User < ApplicationRecord
  # Макрос Rails: добавляет виртуальные атрибуты password / password_confirmation,
  # хеширует пароль через bcrypt в поле password_digest и метод authenticate(password)
  has_secure_password

  has_many :evaluations, dependent: :destroy
  has_many :rated_books, through: :evaluations, source: :book

  # Приводим e-mail к единому виду до валидации, чтобы "Ivan@Mail.ru " и "ivan@mail.ru" были одним логином
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP },
            length: { maximum: 255 }

  validates :password,
            length: { minimum: 6, maximum: 72 },
            allow_nil: true

  # Средняя оценка пользователя по всем книгам (nil, если оценок ещё нет)
  def average_rating
    evaluations.average(:rating)&.round(1)
  end

  # Любимый жанр — жанр с максимальной средней оценкой пользователя
  def favourite_genre
    stats = evaluations.joins(:book).group("books.genre_id").average(:rating)
    return nil if stats.empty?

    best_genre_id = stats.max_by { |_genre_id, avg| avg }.first
    Genre.find_by(id: best_genre_id)
  end
end
