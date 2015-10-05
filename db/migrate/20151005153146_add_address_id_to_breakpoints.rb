class AddAddressIdToBreakpoints < ActiveRecord::Migration
  def change
    add_column :breakpoints, :address_id, :integer
  end
end
