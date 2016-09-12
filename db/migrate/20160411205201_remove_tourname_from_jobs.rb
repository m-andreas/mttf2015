class RemoveTournameFromJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :tourname, :string
  end
end
