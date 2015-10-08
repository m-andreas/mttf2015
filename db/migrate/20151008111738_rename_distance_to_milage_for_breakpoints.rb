class RenameDistanceToMilageForBreakpoints < ActiveRecord::Migration
  def change
    rename_column :breakpoints, :distance, :mileage
  end
end
