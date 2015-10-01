class AddBillIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :bill_id, :integer
  end
end
