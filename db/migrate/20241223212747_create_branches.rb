class CreateBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :branches do |t|
      t.string :name, null: false
      t.belongs_to :agency, null: false, foreign_key: true

      t.timestamps
    end

    add_index :branches, %i[name agency_id], unique: true
  end
end
