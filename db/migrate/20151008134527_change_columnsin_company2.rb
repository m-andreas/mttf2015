class ChangeColumnsinCompany2 < ActiveRecord::Migration
  def change
    change_column :companies, :price_per_km, :decimal, :precision => 10, :scale => 4
    change_column :companies, :price_flat_rate, :decimal, :precision => 10, :scale => 4
  end
end
