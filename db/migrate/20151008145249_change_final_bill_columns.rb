class ChangeFinalBillColumns < ActiveRecord::Migration
  def change
    change_column :bills, :price_per_km, :decimal, precision: 15, scale: 4
    change_column :bills, :price_flat_rate, :decimal, precision: 15, scale: 4
    change_column :bills, :driver_price_per_km, :decimal, precision: 15, scale: 4
    change_column :bills, :driver_price_flat_rate, :decimal, precision: 15, scale: 4
  end
end
