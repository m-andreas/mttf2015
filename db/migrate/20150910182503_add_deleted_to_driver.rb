class AddDeletedToDriver < ActiveRecord::Migration
  def change
    add_column :drivers, :deleted, :boolean, :default => false
  end
end
