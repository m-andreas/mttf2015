class Job < ActiveRecord::Base
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"
  belongs_to :driver
  has_many :carriers
  has_many :co_jobs, through: :carriers
  has_one :carrier, foreign_key: :co_job_id
  belongs_to :route
  belongs_to :created_by, class_name: "User"
  belongs_to :bill
  paginates_per 10
  validates :driver_id, presence: true
  validates :status, numericality: { only_integer: true }
  has_many :breakpoints, -> { order(:position) }
  accepts_nested_attributes_for :breakpoints
  OPEN = 1
  FINISHED = 2
  CHARGED = 3
  DELETED = 99

  def self.get_active
    where( "status in (:show)", show: [ OPEN, FINISHED, CHARGED ] ).includes( :from, :to )
  end

  def self.get_open
    Job.where( status: OPEN )
  end

  def set_billed bill
    self.status = FINISHED
    self.bill = bill
    self.save
  end

  def set_to_current_bill
    self.set_billed Bill.get_current
  end

  def set_charged
    self.status = CHARGED
    self.save
  end

  def set_open
    self.status = OPEN
    self.bill = nil
    self.save
  end

  def is_open?
    status == OPEN
  end

  def reset_to_current_bill
    self.bill = Bill.get_current
    self.status = FINISHED
    self.save
  end

  def is_finished?
    status == FINISHED
  end

  def is_charged?
    status == CHARGED
  end

  def co_drivers
    co_drivers = []
    co_jobs.each do |co_job|
      co_drivers << co_job.driver
    end
    co_drivers
  end

  def remove_co_job co_job
    carrier = Carrier.where( co_job_id: co_job.id, job_id: self.id ).first
    logger.info carrier.inspect

    Carrier.delete(carrier.id)
    carrier.destroy unless carrier.nil?
  end

  def add_breakpoints
    self.breakpoints = []

    self.co_jobs.each_with_index do |co_job, index|
      logger.info co_job.from.address_short
      if self.breakpoints.where( address_id: co_job.from.id ).empty? && self.to_id != co_job.from_id
        bp = self.breakpoints.build( position: index ,job_id: self.id, address_id: co_job.from.id )
        bp.save
      end
    end
  end

  def add_co_jobs( co_job_ids )
    self.co_jobs = []
    unless co_job_ids.nil? || co_job_ids.empty? || !shuttle
      co_job_ids[0] = "" if co_job_ids[0] == ","
      co_job_ids = co_job_ids.split ","
      jobs = []
      co_job_ids.each do |co_job_id|
        unless co_job_id.to_i == self.id
          co_job = Job.find(co_job_id)
          jobs <<  co_job
        end
      end
      self.co_jobs = jobs
    end
    self.save
  end

  def is_shuttle?
    return self.shuttle
  end

  def shuttle_job
    if self.carrier.present?
      return self.carrier.job
    else
      return nil
    end
  end

  def has_shuttle?
    return self.carrier.present?
  end

  def get_shuttle_array
    shuttle = []
    self.co_jobs.each do |job|
      name = job.driver.nil? ? "" : job.driver.fullname
      shuttle << [ name, job.id ]
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
