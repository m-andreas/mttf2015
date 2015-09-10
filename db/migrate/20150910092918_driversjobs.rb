class Driversjobs < ActiveRecord::Migration
  def change
    create_table 'carriers', :id => false do |t|
      t.column :job_id, :integer
      t.column :driver_id, :integer
      t.column :chauffeur, :boolean
    end
  end
end
