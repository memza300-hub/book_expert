class Genre < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :evaluations, through: :books

  validates :name_ru, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :name_en, presence: true, uniqueness: true, length: { maximum: 100 }

  scope :ordered, -> { order(:id) }

  # Название жанра на текущем языке интерфейса
  def name(locale = I18n.locale)
    locale.to_s == "en" ? name_en : name_ru
  end

  # Книги жанра, которые указанный пользователь ещё не оценил
  def unrated_books_for(user)
    books.where.not(id: user.evaluations.select(:book_id)).order(:id)
  end
end
