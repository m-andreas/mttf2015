class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :customer_job_id
      t.string :mvn
      t.string :driver_ids
      t.integer :cost_center_id
      t.integer :finished
      t.integer :created_by_id
      t.integer :route_id
      t.integer :from_id
      t.integer :to_id
      t.boolean :shuttle
      t.string :car_brand
      t.string :car_type
      t.string :registration_number
      t.string :chassis_number
      t.string :job_notice
      t.string :transport_notice
      t.string :transport_notice_extern
      t.datetime :scheduled_collection_date
      t.datetime :scheduled_delivery_date
      t.datetime :actual_collection_date
      t.datetime :actual_delivery_date
      t.integer :mileage_delivery
      t.integer :mileage_collection
      t.integer :working_hours
      t.float :price_extern
      t.integer :times_printed
      t.boolean :duplicate

      t.timestamps
    end
  end
end
