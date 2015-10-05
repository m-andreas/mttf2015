class AddBankDataToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :iban, :string
    add_column :drivers, :bic, :string
  end
end
