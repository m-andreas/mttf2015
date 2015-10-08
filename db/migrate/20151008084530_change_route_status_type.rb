class ChangeRouteStatusType < ActiveRecord::Migration
  def change
    change_column :routes, :status, :integer
  end
end
