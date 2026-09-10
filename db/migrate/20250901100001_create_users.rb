class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email,           null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    # E-mail является логином, поэтому должен быть уникальным
    add_index :users, :email, unique: true
  end
end
