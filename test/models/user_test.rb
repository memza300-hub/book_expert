require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user is saved" do
    user = User.new(email: "new@example.com", password: "secret1", password_confirmation: "secret1")
    assert user.save
  end

  test "email is required" do
    user = User.new(email: "", password: "secret1", password_confirmation: "secret1")
    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email
  end

  test "email is normalized and unique regardless of case" do
    user = User.new(email: "  Expert@Example.COM ", password: "secret1", password_confirmation: "secret1")
    assert_not user.valid?
    assert_equal "expert@example.com", user.email
    assert_includes user.errors.attribute_names, :email
  end

  test "password shorter than 6 characters is rejected" do
    user = User.new(email: "short@example.com", password: "12345", password_confirmation: "12345")
    assert_not user.valid?
    assert_includes user.errors.attribute_names, :password
  end

  test "authenticate accepts the right password and rejects a wrong one" do
    user = users(:expert)
    assert user.authenticate("password")
    assert_not user.authenticate("wrong")
  end
end
