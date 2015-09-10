class RemoveDriverIdsFromJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :driver_ids, :string
  end
end
