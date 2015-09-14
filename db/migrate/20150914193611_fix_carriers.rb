class FixCarriers < ActiveRecord::Migration
  def change
    Carrier.delete_all
    remove_column :carriers, :chauffeur
  end
end
