class CreateEnterprises < ActiveRecord::Migration[8.0]
  def change
    create_table :enterprises do |t|
      t.string :name, null: false
      t.integer :category, default: 0
      t.jsonb :location, default: {}
      t.integer :marketer_id
      t.string :city
      t.text :description

      t.timestamps
    end

    add_index :enterprises, :name, unique: true
  end
end
