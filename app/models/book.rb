class Book < ApplicationRecord
  belongs_to :genre
  has_many :evaluations, dependent: :destroy
  has_many :experts, through: :evaluations, source: :user

  validates :title_ru, :title_en, presence: true, length: { maximum: 255 }
  validates :author_ru, :author_en, presence: true, length: { maximum: 255 }
  validates :description_ru, :description_en, presence: true
  validates :year,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 2100 },
            allow_nil: true
  validates :image_url, length: { maximum: 2048 }, allow_blank: true

  scope :ordered, -> { order(:id) }

  # Локализованные атрибуты: одно поле в БД на каждый язык,
  # один метод в модели, выбирающий значение по текущей локали
  def title(locale = I18n.locale)
    locale.to_s == "en" ? title_en : title_ru
  end

  def author(locale = I18n.locale)
    locale.to_s == "en" ? author_en : author_ru
  end

  def description(locale = I18n.locale)
    locale.to_s == "en" ? description_en : description_ru
  end

  # Средняя оценка книги по всем экспертам
  def average_rating
    evaluations.average(:rating)&.round(1)
  end
end
