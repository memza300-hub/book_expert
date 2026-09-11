require "test_helper"

module Api
  module V1
    class BooksApiControllerTest < ActionDispatch::IntegrationTest
      def api_get(params = {})
        get api_v1_books_path, params: params, headers: { "Accept" => "application/json" }
        JSON.parse(response.body)
      end

      def api_post(payload)
        post api_v1_books_path, params: payload.to_json,
             headers: { "Content-Type" => "application/json", "Accept" => "application/json" }
        JSON.parse(response.body)
      end

      test "index without session returns 401 json" do
        body = api_get(genre_id: genres(:classics).id)
        assert_response :unauthorized
        assert_equal I18n.t("api.unauthorized"), body["error"]
      end

      test "index without genre_id returns 400" do
        log_in_as(users(:expert))
        api_get
        assert_response :bad_request
      end

      test "index with unknown genre returns 404" do
        log_in_as(users(:expert))
        api_get(genre_id: 999_999)
        assert_response :not_found
      end

      test "index skips books already rated by the current user" do
        log_in_as(users(:expert))
        body = api_get(genre_id: genres(:classics).id)
        assert_response :success
        assert_equal false, body["done"]
        assert_equal 2, body["total"]
        assert_equal 1, body["rated"]
        assert_equal books(:master).id, body["book"]["id"]
        assert_equal "Мастер и Маргарита", body["book"]["title"]
      end

      test "index returns the first book for a user without ratings" do
        log_in_as(users(:reader))
        body = api_get(genre_id: genres(:classics).id)
        assert_equal 0, body["rated"]
        assert_equal books(:crime).id, body["book"]["id"]
      end

      test "index reports done when every book of the genre is rated" do
        Evaluation.create!(user: users(:expert), book: books(:master), rating: 70)
        log_in_as(users(:expert))
        body = api_get(genre_id: genres(:classics).id)
        assert_equal true, body["done"]
        assert_nil body["book"]
        assert_equal 2, body["rated"]
      end

      test "index localizes the book title" do
        log_in_as(users(:reader))
        body = api_get(genre_id: genres(:scifi).id, locale: "en")
        assert_equal "Dune", body["book"]["title"]
      end

      test "create saves a valid evaluation" do
        log_in_as(users(:reader))
        assert_difference("Evaluation.count", 1) do
          body = api_post(book_id: books(:dune).id, rating: 88, comment: "Great")
          assert_response :created
          assert_equal "created", body["status"]
          assert_equal 88, body["evaluation"]["rating"]
          assert_equal 1, body["rated_total"]
        end
        evaluation = Evaluation.last
        assert_equal users(:reader), evaluation.user
        assert_equal "Great", evaluation.comment
      end

      test "create rejects rating outside 1..100" do
        log_in_as(users(:reader))
        assert_no_difference("Evaluation.count") do
          body = api_post(book_id: books(:dune).id, rating: 150, comment: "")
          assert_response :unprocessable_entity
          assert_equal "error", body["status"]
          assert body["errors"].any?
        end
      end

      test "create rejects a second evaluation of the same book" do
        log_in_as(users(:expert))
        assert_no_difference("Evaluation.count") do
          api_post(book_id: books(:crime).id, rating: 10, comment: "")
          assert_response :unprocessable_entity
        end
      end

      test "create with unknown book returns 404" do
        log_in_as(users(:reader))
        api_post(book_id: 999_999, rating: 50, comment: "")
        assert_response :not_found
      end

      test "create without session returns 401 and saves nothing" do
        assert_no_difference("Evaluation.count") do
          api_post(book_id: books(:dune).id, rating: 50, comment: "")
          assert_response :unauthorized
        end
      end

      test "create without csrf token is rejected when forgery protection is on" do
        log_in_as(users(:reader))
        ActionController::Base.allow_forgery_protection = true
        assert_no_difference("Evaluation.count") do
          api_post(book_id: books(:dune).id, rating: 50, comment: "")
          assert_not_equal 201, response.status
        end
      ensure
        ActionController::Base.allow_forgery_protection = false
      end
    end
  end
end
