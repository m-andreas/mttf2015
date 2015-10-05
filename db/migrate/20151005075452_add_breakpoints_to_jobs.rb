class AddBreakpointsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :breakpoints, :string
  end
end
