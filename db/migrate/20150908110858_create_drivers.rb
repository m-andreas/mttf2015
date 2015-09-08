class CreateDrivers < ActiveRecord::Migration
  def change
    create_table :drivers do |t|
      t.string :first_name
      t.string :last_name
      t.date :entry_date
      t.date :exit_date
      t.date :date_of_birth
      t.string :place_of_birth
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :telepone
      t.string :telephone2
      t.string :licence_number
      t.string :issuing_authority
      t.string :driving_licence_category
      t.string :comment
      t.string :social_security_number
      t.boolean :driving_licence_copy
      t.boolean :registration_copy
      t.boolean :service_contract

      t.timestamps
    end
  end
end
