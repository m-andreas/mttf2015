class Breakpoint < ActiveRecord::Base
  acts_as_sortable do |config|
    config[:relation] = ->(instance) {instance.job.breakpoints}
  end

  belongs_to :job
  belongs_to :address
end
