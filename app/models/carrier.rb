class Carrier < ActiveRecord::Base
  belongs_to :co_job, class_name: "Job"
  belongs_to :job
end
