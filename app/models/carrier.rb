class Carrier < ActiveRecord::Base
  belongs_to :co_job, class_name: "Job", foreign_key: :co_job_id
  belongs_to :job
end
