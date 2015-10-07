class ChangeColumnsInCompany < ActiveRecord::Migration
  def change
    change_column :companies, :price_per_km, :decimal, :precision => 10, :scale => 2
    change_column :companies, :price_flat_rate, :decimal, :precision => 10, :scale => 2
  end
end
