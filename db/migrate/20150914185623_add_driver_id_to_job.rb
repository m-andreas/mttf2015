class AddDriverIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :driver_id, :integer
  end
end
