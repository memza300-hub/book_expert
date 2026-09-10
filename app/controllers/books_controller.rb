class BooksController < ApplicationController
  before_action :authorize

  # Отдаёт только каркас рабочей области эксперта.
  # Список жанров рендерится на сервере, а карточки книг подгружаются
  # асинхронно через JSON API (app/javascript/books_evaluation.js)
  def index
    @genres = Genre.ordered
    @total_books = Book.count
    @rated_books = current_user.evaluations.count
  end
end
