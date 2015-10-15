class AddDatesToDelivery < ActiveRecord::Migration
  def change
    Job.find_each(batch_size: 1000) do |job|
      job.scheduled_collection_time = job.scheduled_collection_date unless job.scheduled_collection_date.nil?
      job.scheduled_delivery_time = job.scheduled_delivery_date unless job.scheduled_delivery_date.nil?
      job.actual_collection_time = job.actual_collection_date unless job.actual_collection_date.nil?
      job.actual_delivery_time = job.actual_delivery_date unless job.actual_delivery_date.nil?
      job.save
    end
  end
end
