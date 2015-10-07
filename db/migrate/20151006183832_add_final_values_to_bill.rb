class AddFinalValuesToBill < ActiveRecord::Migration
  def change
    add_column :bills, :price_km, :decimal, precision: 15, scale: 2
    add_column :bills, :price_flat, :decimal, precision: 15, scale: 2
    add_column :bills, :driver_price_km, :decimal, precision: 15, scale: 2
    add_column :bills, :driver_price_flat, :decimal, precision: 15, scale: 2
  end
end
