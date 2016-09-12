class RemoveOldShuttles < ActiveRecord::Migration
  def up
  	drop_table :carriers 
  	drop_table :breakpoints
  end

  def down
    create_table 'carriers', :id => false do |t|
      t.column :job_id, :integer
      t.column :co_job_id, :integer
    end
    create_table :breakpoints do |t|
      t.integer :position
      t.integer :job_id
      t.integer :mileage
      t.integer :address_id
      t.timestamps
    end
  end
end
