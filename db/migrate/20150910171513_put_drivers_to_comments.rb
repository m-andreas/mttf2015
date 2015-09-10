class PutDriversToComments < ActiveRecord::Migration
  def up
    i=1
    Job.find_each(batch_size: 1000) do |job|
      if job.co_drivers.length > 0
        job.transport_notice += "Beifahrer: "
        job.co_drivers.each do |driver|
          job.transport_notice += "#{driver.fullname}, " unless driver.nil?
        end
        job.save
      end
      if i % 1000 == 0
        puts "Processed #{i} Jobs"
      end
      i += 1
    end
  end
end
