require "test_helper"

class EvaluationTest < ActiveSupport::TestCase
  def build_evaluation(rating)
    Evaluation.new(user: users(:reader), book: books(:crime), rating: rating)
  end

  test "rating 1 and 100 are valid" do
    assert build_evaluation(1).valid?
    assert build_evaluation(100).valid?
  end

  test "rating 0 and 101 are rejected" do
    assert_not build_evaluation(0).valid?
    assert_not build_evaluation(101).valid?
  end

  test "non-integer rating is rejected" do
    assert_not build_evaluation(55.5).valid?
  end

  test "user cannot rate the same book twice" do
    duplicate = Evaluation.new(user: users(:expert), book: books(:crime), rating: 50)
    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :user_id
  end

  test "comment longer than 2000 characters is rejected" do
    evaluation = build_evaluation(50)
    evaluation.comment = "a" * 2001
    assert_not evaluation.valid?
  end

  test "to_csv contains headers and the rated book" do
    csv = Evaluation.to_csv(users(:expert).evaluations, locale: :ru)
    lines = csv.lines
    assert_equal 2, lines.size
    assert_includes lines.first, I18n.t("csv.headers.title", locale: :ru)
    assert_includes lines.last, "Преступление и наказание"
    assert_includes lines.last, "90"
  end
end
