class CreateGenres < ActiveRecord::Migration[8.0]
  def change
    create_table :genres do |t|
      t.string :name_ru, null: false
      t.string :name_en, null: false

      t.timestamps
    end

    add_index :genres, :name_ru, unique: true
    add_index :genres, :name_en, unique: true
  end
end
