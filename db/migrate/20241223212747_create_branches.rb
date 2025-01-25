class CreateBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :branches do |t|
      t.string :name, null: false
      t.string :telephone, null: false
      t.belongs_to :enterprise, null: false, foreign_key: true

      t.timestamps
    end

    add_index :branches, %i[name enterprise_id], unique: true
    add_index :branches, %i[telephone enterprise_id], unique: true
  end
end
