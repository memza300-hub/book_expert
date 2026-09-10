module Api
  module V1
    # JSON REST API for the expert workspace.
    #
    #   GET  /api/v1/books?genre_id=1  -> next unrated book of the genre for the current user
    #   POST /api/v1/books             -> save rating (1-100) and comment for a book
    #
    # The session cookie of the logged-in user is reused, so the API is protected
    # by the same manual session mechanism as the rest of the application.
    class BooksApiController < ApplicationController
      # JSON body is read as top-level params; no need to wrap it under "books_api"
      wrap_parameters false

      before_action :authorize_api

      # Returns the first book of the genre that the current user has not rated yet.
      # When every book is rated, returns { done: true } with progress counters.
      def index
        genre_id = params[:genre_id].presence
        return render_error(I18n.t("api.genre_required"), :bad_request) if genre_id.nil?

        genre = Genre.find_by(id: genre_id)
        return render_error(I18n.t("api.genre_not_found"), :not_found) if genre.nil?

        all_books  = genre.books.ordered
        rated_ids  = current_user.evaluations.where(book_id: all_books.select(:id)).pluck(:book_id)
        next_book  = all_books.where.not(id: rated_ids).first

        payload = {
          genre_id: genre.id,
          genre: genre.name,
          total: all_books.size,
          rated: rated_ids.size,
          done: next_book.nil?
        }
        payload[:book] = BookSerializer.new(next_book).as_json if next_book

        render json: payload, status: :ok
      end

      # Creates an evaluation for the current user.
      # Expected JSON body: { "book_id": 3, "rating": 87, "comment": "..." }
      def create
        book = Book.find_by(id: evaluation_params[:book_id])
        return render_error(I18n.t("api.book_not_found"), :not_found) if book.nil?

        evaluation = current_user.evaluations.build(
          book: book,
          rating: evaluation_params[:rating],
          comment: evaluation_params[:comment].to_s.strip
        )

        if evaluation.save
          render json: {
            status: "created",
            message: I18n.t("api.created"),
            evaluation: EvaluationSerializer.new(evaluation).as_json,
            rated_total: current_user.evaluations.count
          }, status: :created
        else
          render json: {
            status: "error",
            errors: evaluation.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      # The API answers 401 in JSON instead of redirecting to the login page
      def authorize_api
        return if logged_in?

        render json: { error: I18n.t("api.unauthorized"), status: :unauthorized }, status: :unauthorized
      end

      def evaluation_params
        params.slice(:book_id, :rating, :comment).permit(:book_id, :rating, :comment)
      end

      def render_error(message, status)
        render json: { error: message, status: status }, status: status
      end
    end
  end
end
