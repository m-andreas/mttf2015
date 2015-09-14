class FixCarriers2 < ActiveRecord::Migration
  def change
    rename_column :carriers, :driver_id, :co_job_id
  end
end
