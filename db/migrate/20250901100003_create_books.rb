class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string  :title_ru,       null: false
      t.string  :title_en,       null: false
      t.string  :author_ru,      null: false
      t.string  :author_en,      null: false
      t.text    :description_ru, null: false
      t.text    :description_en, null: false
      t.integer :year
      t.string  :image_url
      # Внешний ключ на жанр: books.genre_id -> genres.id
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end
  end
end
