class CreatePassengers < ActiveRecord::Migration
  def change
    create_table :passengers do |t|
      t.integer :job_id
      t.integer :driver_id

      t.timestamps
    end
  end
end
