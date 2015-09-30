class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.datetime :billed_at
      t.string :print_date

      t.timestamps
    end
  end
end
