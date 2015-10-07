class AddFinalValuesToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :final_distance, :integer
    add_column :jobs, :final_calculation_basis, :integer
  end
end
