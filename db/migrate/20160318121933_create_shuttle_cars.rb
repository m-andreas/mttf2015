class CreateShuttleCars < ActiveRecord::Migration
  def change
    create_table :shuttle_cars do |t|
      t.string :car_brand
      t.string :car_type
      t.string :registration_number

      t.timestamps
    end
  end
end
