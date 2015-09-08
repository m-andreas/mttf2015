class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.integer :from_id
      t.integer :to_id
      t.integer :calculation_basis
      t.integer :distance
      t.integer :last_modified_by 
      t.string :status

      t.timestamps
    end
  end
end
