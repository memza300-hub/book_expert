require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "workspace requires login" do
    get books_path
    assert_redirected_to login_path
  end

  test "profile requires login" do
    get profile_path
    assert_redirected_to login_path
  end

  test "workspace renders genres for a logged in user" do
    log_in_as(users(:expert))
    get books_path
    assert_response :success
    assert_select "select#genre-select option", minimum: 3
    assert_select "input#rating-range[min=?][max=?]", "1", "100"
  end

  test "english locale switches interface texts" do
    log_in_as(users(:expert))
    get books_path(locale: :en)
    assert_response :success
    assert_select "h1", text: I18n.t("books.index.title", locale: :en)
  end
end
