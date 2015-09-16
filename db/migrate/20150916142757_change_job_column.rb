class ChangeJobColumn < ActiveRecord::Migration
  def change
    rename_column :jobs, :finished, :status
  end
end
