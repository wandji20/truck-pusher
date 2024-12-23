class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :telephone, null: false
      t.integer :invited_by
      t.datetime :invited_at
      t.boolean :confirmed, default: false
      t.integer :agency_id, null: false
      t.integer :branch_id
      t.integer :role, default: 0
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :telephone, unique: true
  end
end
