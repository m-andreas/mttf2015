class AddAbroadTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :abroad_time_start, :time
    add_column :jobs, :abroad_time_end, :time
  end
end
