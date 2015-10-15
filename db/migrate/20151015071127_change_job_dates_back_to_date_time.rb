class ChangeJobDatesBackToDateTime < ActiveRecord::Migration
  def change
    add_column :jobs, :scheduled_collection_time, :datetime
    add_column :jobs, :scheduled_delivery_time, :datetime
    add_column :jobs, :actual_collection_time, :datetime
    add_column :jobs, :actual_delivery_time, :datetime
  end
end
