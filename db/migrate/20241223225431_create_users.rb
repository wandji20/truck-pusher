class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :type
      t.string :full_name
      t.string :telephone, null: false
      t.integer :invited_by_id
      t.datetime :invited_at
      t.boolean :confirmed, default: false
      t.boolean :archived, default: false
      t.integer :enterprise_id
      t.integer :branch_id
      t.integer :role
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, %i[telephone enterprise_id], unique: true
  end
end
