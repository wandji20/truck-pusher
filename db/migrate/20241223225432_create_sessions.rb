class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: true, foreign_key: true
      t.references :marketer, null: true, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.integer :enterprise_id

      t.timestamps
    end
  end
end
