class AddDisplayNameToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :display_name, :string
  end
end
