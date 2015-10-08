class Breakpoint < ActiveRecord::Base
  belongs_to :job
  belongs_to :address
  acts_as_sortable do |config|
    config[:relation] = ->(instance) {instance.job.breakpoints}
  end

  def distance
    if self.position == 0
      return self.mileage.to_i - self.job.mileage_collection.to_i
    else
      position_before = self.position - 1
      breakpoint_before = Breakpoint.find_by( job_id: self.job.id, position: position_before )
      return self.mileage.to_i - breakpoint_before.mileage.to_i
    end
  end
end
