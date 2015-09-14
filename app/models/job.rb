class Job < ActiveRecord::Base
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"
  belongs_to :driver
  has_many :carriers
  has_many :co_jobs, through: :carriers
  belongs_to :route
  belongs_to :created_by, class_name: "User"
  paginates_per 10
  def co_drivers
    co_drivers = []
    co_jobs.each do |co_job|
      co_drivers << co_job.driver
    end
    co_drivers
  end

  def add_co_jobs( co_job_ids )
    unless co_jobs.nil? || co_job_ids.empty? || !shuttle
      co_job_ids[0] = ""
      co_job_ids = co_job_ids.split ","
      jobs = []
      co_job_ids.each do |co_job|
        jobs << Job.find(co_job)
      end
      puts jobs.inspect
      self.co_jobs = jobs
    else
      return true
    end
  end
end
