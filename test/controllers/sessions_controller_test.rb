require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login page is available" do
    get login_path
    assert_response :success
    assert_select "form"
  end

  test "login with correct password redirects to the workspace" do
    log_in_as(users(:expert))
    assert_redirected_to books_path
    follow_redirect!
    assert_response :success
    assert_select ".site-nav__user", text: users(:expert).email
  end

  test "login with wrong password re-renders the form" do
    log_in_as(users(:expert), password: "wrong")
    assert_response :unprocessable_entity
    assert_select ".flash--alert"
  end

  test "logout clears the session and protects the workspace again" do
    log_in_as(users(:expert))
    delete logout_path
    assert_redirected_to login_path

    get books_path
    assert_redirected_to login_path
  end
end
