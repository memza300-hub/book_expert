require "csv"

class Evaluation < ApplicationRecord
  MIN_RATING = 1
  MAX_RATING = 100

  belongs_to :user
  belongs_to :book

  # Rating is a continuous 1..100 slider value; only integers are stored
  validates :rating,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: MIN_RATING,
              less_than_or_equal_to: MAX_RATING
            }

  # One user may rate one book only once
  validates :user_id, uniqueness: { scope: :book_id }

  validates :comment, length: { maximum: 2000 }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }
  scope :with_books, -> { includes(book: :genre) }

  # Builds a CSV document for the given collection of evaluations.
  # Used by ProfilesController#export: Evaluation.to_csv(current_user.evaluations)
  def self.to_csv(evaluations, locale: I18n.locale)
    headers = %i[id genre title author year rating comment created_at].map do |key|
      I18n.t("csv.headers.#{key}", locale: locale)
    end

    CSV.generate(col_sep: ";", headers: true, write_headers: true) do |csv|
      csv << headers

      evaluations.includes(book: :genre).order(:created_at).each do |evaluation|
        book = evaluation.book
        csv << [
          evaluation.id,
          book.genre.name(locale),
          book.title(locale),
          book.author(locale),
          book.year,
          evaluation.rating,
          evaluation.comment.to_s.strip,
          I18n.l(evaluation.created_at, format: :default, locale: locale)
        ]
      end
    end
  end

  # Human-readable verbal category for the numeric rating (used in the profile)
  def verdict_key
    case rating
    when 1..20  then "terrible"
    when 21..40 then "weak"
    when 41..60 then "average"
    when 61..80 then "good"
    else             "masterpiece"
    end
  end
end
