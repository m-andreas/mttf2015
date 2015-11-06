class AddToPrintToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :to_print, :boolean, :default => true
  end
end
