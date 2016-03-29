class AddShuttleDataToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :shuttle_data, :string
  end
end
