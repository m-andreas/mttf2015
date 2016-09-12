class AddTournameToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :tourname, :string
  end
end
