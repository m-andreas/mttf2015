class ChangeFormatOfShuttleData < ActiveRecord::Migration
  def up
    change_column :jobs, :shuttle_data, :text
  end

  def down
    change_column :jobs, :shuttle_data, :string
  end
end
