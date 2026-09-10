class CreateEvaluations < ActiveRecord::Migration[8.0]
  def change
    create_table :evaluations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :rating,  null: false
      t.text    :comment

      t.timestamps
    end

    # Один пользователь может оценить одну книгу только один раз:
    # составной уникальный индекс дублирует валидацию модели на уровне БД
    add_index :evaluations, [:user_id, :book_id], unique: true

    # Диапазон оценки контролируется и на уровне СУБД
    add_check_constraint :evaluations, "rating >= 1 AND rating <= 100", name: "evaluations_rating_range"
  end
end
