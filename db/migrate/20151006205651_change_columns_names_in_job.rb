class ChangeColumnsNamesInJob < ActiveRecord::Migration
  def change
    rename_column :bills, :price_flat, :price_flat_rate
    rename_column :bills, :driver_price_flat, :driver_price_flat_rate
    rename_column :bills, :price_km, :price_per_km
    rename_column :bills, :driver_price_km, :driver_price_per_km
  end
end
