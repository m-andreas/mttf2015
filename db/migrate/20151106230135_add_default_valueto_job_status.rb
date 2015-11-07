class AddDefaultValuetoJobStatus < ActiveRecord::Migration
  def change
    def up
      change_column :jobs, :status, :integer, :default => 1
    end

    def down
      change_column :jobs, :status, :integer, :default => nil
    end
  end
end
