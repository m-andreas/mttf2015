class FixColumnName < ActiveRecord::Migration
  def up
    i=1
    Job.find_each(batch_size: 1000) do |job|
      job.driver_id = job.main_driver.id unless job.main_driver.nil?
      job.save!
      if i % 1000 == 0
        puts "Processed #{i} Jobs"
      end
      i += 1
    end
  end
end
