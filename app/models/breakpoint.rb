class Breakpoint < ActiveRecord::Base
  belongs_to :job
  belongs_to :address
  acts_as_sortable do |config|
    config[:relation] = ->(instance) {instance.job.breakpoints}
  end

  def previous
    breakpoints_list = self.job.breakpoints.order(:position)
    index = breakpoints_list.index(self)
    return breakpoints_list[ index - 1 ]
  end

  def first_position?
    breakpoints_list = self.job.breakpoints.order(:position)
    index = breakpoints_list.index(self)
    return index == 0
  end

  def distance
    if self.first_position?
      return self.mileage.to_i - self.job.mileage_collection.to_i
    else
      breakpoint_before = self.previous
      return self.mileage.to_i - breakpoint_before.mileage.to_i
    end
  end
end
