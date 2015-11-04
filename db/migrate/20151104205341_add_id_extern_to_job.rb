class AddIdExternToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :id_extern, :integer
  end
end
