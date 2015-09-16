class Job < ActiveRecord::Base
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"
  belongs_to :driver
  has_many :carriers
  has_many :co_jobs, through: :carriers
  belongs_to :route
  belongs_to :created_by, class_name: "User"
  paginates_per 10
  validates :driver_id, presence: true
  validates :status, numericality: { only_integer: true }
  OPEN = 1
  FINISHED = 2
  CHARGED = 3
  DELETED = 99

  def co_drivers
    co_drivers = []
    co_jobs.each do |co_job|
      co_drivers << co_job.driver
    end
    co_drivers
  end

  def add_co_jobs( co_job_ids )
    unless co_job_ids.nil? || co_job_ids.empty? || !shuttle
      co_job_ids[0] = "" if co_job_ids[0] == ","
      co_job_ids = co_job_ids.split ","
      jobs = []
      co_job_ids.each do |co_job|
        jobs << Job.find(co_job) unless co_job.to_i == self.id
      end
      self.co_jobs = jobs
    else
      self.co_jobs = []
      return true
    end
  end

  def is_shuttle?
    return self.shuttle
  end

  def get_shuttle_array
    shuttle = []
    self.co_jobs.each do |job|
      shuttle << [ job.driver.fullname, job.id ]
    end
    shuttle
  end

  def get_co_jobs_string
    co_jobs_string = ""
    self.co_jobs.each do |job|
      co_jobs_string += "," + job.id.to_s
    end
    co_jobs_string
  end

  def charged?
    self.status == CHARGED
  end

  def get_status
    case self.status
    when OPEN
      return "Offen"
    when FINISHED
      return "Abgeschlossen"
    when CHARGED
      return "Verrechnet"
    when DELETED
      return "Gelöscht"
    else
      return "Status nicht bekannt"
    end
  end
end
