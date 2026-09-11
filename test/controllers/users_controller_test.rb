require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "signup creates a user and logs in" do
    assert_difference("User.count", 1) do
      post signup_path, params: { user: { email: "fresh@example.com", password: "secret1", password_confirmation: "secret1" } }
    end
    assert_redirected_to books_path
    follow_redirect!
    assert_select ".site-nav__user", text: "fresh@example.com"
  end

  test "signup with mismatched password confirmation fails" do
    assert_no_difference("User.count") do
      post signup_path, params: { user: { email: "fresh@example.com", password: "secret1", password_confirmation: "other1" } }
    end
    assert_response :unprocessable_entity
    assert_select ".form__errors"
  end
end
