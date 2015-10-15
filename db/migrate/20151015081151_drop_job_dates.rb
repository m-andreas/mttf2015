class DropJobDates < ActiveRecord::Migration
  def change
    remove_column :jobs, :scheduled_collection_date
    remove_column :jobs, :scheduled_delivery_date
    remove_column :jobs, :actual_collection_date
    remove_column :jobs, :actual_delivery_date
  end
end
