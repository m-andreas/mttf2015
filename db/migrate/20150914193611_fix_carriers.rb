class FixCarriers < ActiveRecord::Migration
  def change
    remove_column :carriers, :chauffeur
  end
end
