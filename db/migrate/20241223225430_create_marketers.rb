class CreateMarketers < ActiveRecord::Migration[8.0]
  def change
    create_table :marketers do |t|
      t.string :full_name
      t.string :telephone
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :enterprises_count, default: 0
      t.boolean :confirmed, default: false

      t.timestamps
    end
  end
end
