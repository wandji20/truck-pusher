class CreateDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :deliveries do |t|
      t.integer :agency_id, null: false

      t.integer :origin_id, null: false
      t.integer :destination_id, null: false
      t.integer :sender_id, null: false
      t.integer :receiver_id, null: false
      # the operator who collected parcel from origin branch
      t.integer :registered_by_id, null: false
      # the operator who checked in parcel at destination branch
      t.integer :checked_in_by_id
      # the operator who released parcel to receiver at destination branch
      t.integer :checked_out_by_id

      t.datetime :checked_in_at
      t.datetime :checked_out_at
      t.integer :status, default: 0

      t.string :tracking_number, null: false
      t.string :tracking_secret, null: false
      t.text :description

      t.timestamps
    end

    add_index :deliveries, :agency_id
    add_index :deliveries, :origin_id
    add_index :deliveries, :destination_id
    add_index :deliveries, :sender_id
    add_index :deliveries, :receiver_id
    add_index :deliveries, %i[tracking_number agency_id]
    add_index :deliveries, %i[tracking_secret agency_id]
  end
end
