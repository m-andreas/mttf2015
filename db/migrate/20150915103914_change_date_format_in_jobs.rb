class ChangeDateFormatInJobs < ActiveRecord::Migration
  def change
    change_column :jobs, :scheduled_collection_date, :date
    change_column :jobs, :scheduled_delivery_date, :date
    change_column :jobs, :actual_collection_date, :date
    change_column :jobs, :actual_delivery_date, :date
  end
end
