class CreateBreakpoints < ActiveRecord::Migration
  def change
    create_table :breakpoints do |t|
      t.integer :position
      t.integer :job_id
      t.integer :distance

      t.timestamps
    end
  end
end
