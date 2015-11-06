#encoding: utf-8
class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :country
      t.string :telephone
      t.string :email
      t.float :price_per_km, scale: 2
      t.float :price_flat_rate, scale: 2
      t.timestamps
    end
  end
end
