require "test_helper"

class GenreTest < ActiveSupport::TestCase
  test "unrated_books_for skips books already rated by the user" do
    unrated = genres(:classics).unrated_books_for(users(:expert))
    assert_equal [books(:master)], unrated.to_a
  end

  test "unrated_books_for returns all books for a user without ratings" do
    unrated = genres(:classics).unrated_books_for(users(:reader))
    assert_equal 2, unrated.count
  end

  test "name follows the locale" do
    genre = genres(:classics)
    assert_equal "Русская классика", genre.name(:ru)
    assert_equal "Russian classics", genre.name(:en)
  end
end
