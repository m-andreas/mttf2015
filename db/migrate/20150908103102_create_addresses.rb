class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :created_by
      t.string :country
      t.string :city
      t.string :zip_code
      t.string :address
      t.string :address_short
      t.boolean :inactive
      t.string :opening_hours

      t.timestamps
    end
  end
end
