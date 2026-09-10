class ProfilesController < ApplicationController
  before_action :authorize

  # Личный кабинет: список оценённых книг и статистика
  def show
    @evaluations = current_user.evaluations.with_books.recent

    @total   = @evaluations.size
    @average = current_user.average_rating
    @best    = @evaluations.max_by(&:rating)
    @worst   = @evaluations.min_by(&:rating)

    # Статистика по жанрам: [[Genre, count, average], ...]
    @genre_stats = @evaluations
      .group_by { |evaluation| evaluation.book.genre }
      .map { |genre, evals| [genre, evals.size, (evals.sum(&:rating).to_f / evals.size).round(1)] }
      .sort_by { |_genre, _count, avg| -avg }

    @favourite_genre = current_user.favourite_genre
    @has_unrated_in_favourite = @favourite_genre.present? &&
      @favourite_genre.unrated_books_for(current_user).exists?
  end

  # Экспорт всех оценок пользователя в CSV-файл
  def export
    csv_data = Evaluation.to_csv(current_user.evaluations, locale: I18n.locale)

    # BOM в начале файла нужен, чтобы Excel корректно распознал UTF-8 и кириллицу
    send_data "\uFEFF" + csv_data,
              filename: "my_evaluations.csv",
              type: "text/csv; charset=utf-8",
              disposition: "attachment"
  end
end
