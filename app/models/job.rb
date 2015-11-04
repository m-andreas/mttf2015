class Job < ActiveRecord::Base
  include ERB::Util
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"
  belongs_to :driver
  has_many :carriers, foreign_key: :job_id, :dependent => :destroy
  has_many :co_jobs, through: :carriers
  has_one :carrier, foreign_key: :co_job_id, :dependent => :destroy
  belongs_to :route
  belongs_to :created_by, class_name: "User"
  belongs_to :bill
  paginates_per 10
  #validates :driver_id, presence: true
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

  def set_route
    self.route_id = Route.find_or_create( self.from_id , self.to_id )
    self.save
  end

  def distance
    self.mileage_delivery.to_i - self.mileage_collection.to_i
  end

  def price_driver
    if self.final_calculation_basis == Route::FLAT_RATE
      price = self.bill.driver_price_flat_rate
    elsif self.final_calculation_basis == Route::PAY_PER_KM
      price = self.distance * self.bill.driver_price_per_km
    else
      return false
    end
    return price
  end

  def get_shuttle_string
    shuttle_string = ""
    if self.is_shuttle?
      shuttle_string = I18n.t("jobs.shuttle_for_jobs")
      self.co_jobs.each do |co_job|
        if co_job == self.co_jobs.last
          shuttle_string += " #{co_job.id}"
        else
          shuttle_string += " #{co_job.id},"
        end
      end
    end
    return shuttle_string
  end

  def delete
    self.remove_shuttles
    self.remove_in_shuttles
    self.status = DELETED
    self.save
  end

  def price_driver_shuttle( driver_job, get_array = false )
    drivers_in_car = self.co_jobs.length + 1
    breakpoints = self.breakpoints.order( :position )
    breakpoints_array = []
    price = 0
    breakpoints.each_with_index do |breakpoint, i|
      part_price = (( self.bill.driver_price_per_km * breakpoint.distance )/ drivers_in_car )
      price += part_price
      if get_array
        if breakpoint.first_position?
          breakpoints_array << [ self.from.address_short, breakpoint.address.address_short, breakpoint.distance, drivers_in_car, part_price ]
        else
          breakpoints_array << [ breakpoints[ i -1 ].address.address_short, breakpoint.address.address_short, breakpoint.distance, drivers_in_car, part_price ]
        end
      end
      if driver_job.from == breakpoint.address
        break
      else
        drivers_leaving = self.co_jobs.where( from_id: breakpoint.address_id ).length
        drivers_in_car -= drivers_leaving
        if breakpoint == breakpoints.last
          part_price = self.bill.driver_price_per_km * ( self.mileage_delivery - breakpoint.mileage ) / drivers_in_car
          price += part_price
          if get_array
            if breakpoint.first_position?
              breakpoints_array << [ self.from.address_short, breakpoint.address.address_short, breakpoint.distance, drivers_in_car, part_price ]
            else
              breakpoints_array << [ breakpoints[ i -1 ].address.address_short, breakpoint.address.address_short, breakpoint.distance, drivers_in_car, part_price ]
            end
          end
        end
      end
    end
    if breakpoints.empty?
      price = self.bill.driver_price_per_km * (job.distance ) / drivers_in_car
      if get_array
        breakpoints_array << [ self.from.address_short, self.from.address_short, job.distance, drivers_in_car, price ]
      end
    end

    if get_array
      return breakpoints_array
    else
      return price
    end
  end

  def price_sixt
    if self.final_calculation_basis == Route::FLAT_RATE
      price = self.bill.price_flat_rate
    elsif self.final_calculation_basis == Route::PAY_PER_KM
      price = self.distance * self.bill.price_per_km
    else
      return false
    end
    return price
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

  def check_for_billing
    unless self.route.is_active?
      error = "Route ist noch nicht gesetzt. Auftrag nicht verrechnet. Auftrag #{self.id}"
      return error
    end
    unless self.mileage_collection.to_i > 0 && self.mileage_delivery.to_i > 0
      error = "Km Stand nicht gesetz. Auftrag nicht verrechnet. Auftrag #{self.id}"
      return error
    end
    unless self.mileage_collection.to_i < self.mileage_delivery.to_i
      error = html_escape ( I18n.translate("jobs.not_billed_date_not_correct") + self.id.to_s ).encode("ISO-8859-1")
      return error
    end
    if self.is_shuttle?
      unless self.breakpoints.empty?
        current_mileage = self.mileage_collection
        self.breakpoints.order( :position ).each do |breakpoint|
          if breakpoint.mileage.nil?
            error = I18n.t("jobs.not_billed_milage_breakpoint") + self.id.to_s
            return error
          end
          if breakpoint.mileage <= current_mileage
            error = html_escape ( I18n.t("jobs.not_billed_breakpoints_not_correct") + self.id.to_s ).encode("ISO-8859-1")
            return error
          end
          current_mileage = breakpoint.mileage
        end
      end
    end


    unless self.actual_collection_time.is_a?( Time ) && self.actual_delivery_time.is_a?( Time )
      error = html_escape(I18n.translate("jobs.not_billed_date_not_set") + self.id.to_s ).encode("ISO-8859-1")
      return error
    end

    if self.actual_collection_time > self.actual_delivery_time
      error = "Lieferzeit liegt vor Abholzeit. Auftrag nicht verrechnet. Auftrag #{self.id}"
      return error
    end

    return true
  end

  def check_shuttle_dependencies
    missing_dependencies = []
    error = self.check_for_billing
    missing_dependencies << error unless error == true
    if self.is_shuttle?
      self.co_jobs.each do |co_job|
        unless co_job.bill == self.bill
          missing_dependencies << "Um Shuttle #{self.id} zu verrechnen muss auch Auftrag #{co_job.id} verrechnet werden"
        end
      end
    elsif self.has_shuttle?
      unless self.carrier.job.bill == self.bill
        missing_dependencies << "Um Auftrag #{self.id} zu verrechnen muss auch sein Shuttle #{self.carrier.job.id} verrechnet werden"
      end
    end
    return missing_dependencies
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

  def remove_shuttles
    ActiveRecord::Base.connection.delete("DELETE FROM carriers WHERE job_id=#{self.id};")
    self.reload
    breakpoints.delete_all
  end

  def remove_in_shuttles
    shuttle = self.shuttle_job
    ActiveRecord::Base.connection.delete("DELETE FROM carriers WHERE co_job_id=#{self.id};")
    self.reload
    shuttle.add_breakpoints
  end

  def remove_co_job co_job
    ActiveRecord::Base.connection.delete("DELETE FROM carriers WHERE co_job_id=#{co_job.id} AND job_id=#{self.id};")
    self.reload
  end

  def add_breakpoints
    self.breakpoints = []

    self.co_jobs.each_with_index do |co_job, index|
      if self.breakpoints.where( address_id: co_job.from.id ).empty? && self.to_id != co_job.from_id
        bp = self.breakpoints.build( position: index ,job_id: self.id, address_id: co_job.from.id )
        bp.save
      end
    end
  end

  def check_co_job_ids( co_job_ids )
    co_jobs = self.co_job_ids_to_co_jobs( co_job_ids )
    return check_co_jobs(co_jobs)
  end

  def check_co_jobs( co_jobs )
    driver_ids = self.co_jobs.pluck( :driver_id )
    co_jobs.each do |co_job|
      return "Fahrer kann nicht in eigenem Shuttel sitzen" if self.driver_id == co_job.driver_id
      return "Fahrer kann nicht 2 Mal in Shuttle sitzen" if driver_ids.include? co_job.driver_id
      return "Eine der Fahrten ist bereits in einem anderen Shuttle" if co_job.has_shuttle?
      driver_ids << co_job.driver_id
    end
    return true
  end

  def co_job_ids_to_co_jobs( co_job_ids )
    jobs = []
    unless co_job_ids.nil? || co_job_ids.empty? || !shuttle
      if co_job_ids.is_a? String
        co_job_ids[0] = "" if co_job_ids[0] == ","
        co_job_ids = co_job_ids.split ","
      end
      co_job_ids.each do |co_job_id|
        unless co_job_id.to_i == self.id
          co_job = Job.find(co_job_id)
          jobs <<  co_job
        end
      end
    end
    return jobs
  end

  def add_co_jobs( co_job_ids )
    self.co_jobs = []
    jobs = co_job_ids_to_co_jobs( co_job_ids )
    self.co_jobs = jobs
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
      return I18n.t(:deleted)
    else
      return "Status nicht bekannt"
    end
  end
end
