class Job < ActiveRecord::Base
  include ERB::Util
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"
  belongs_to :driver
  belongs_to :route
  belongs_to :created_by, class_name: "User"
  belongs_to :bill
  has_many :passengers
  paginates_per 10
  #validates :driver_id, presence: true
  validates :status, numericality: { only_integer: true }
  serialize :shuttle_data, JSON
  OPEN = 1
  FINISHED = 2
  CHARGED = 3
  DELETED = 99

  def get_co_driver_ids
    self.passengers.pluck(:driver_id)
  end

  def add_co_driver co_driver
    Passenger.create( {job_id: self.id, driver_id: co_driver.id})
  end

  def add_co_drivers co_driver_ids
    self.remove_co_drivers
    if !co_driver_ids.nil? && co_driver_ids.is_a?( Array )
      co_driver_ids.each do |co_driver_id|
        driver = Driver.find_by(id: co_driver_id)
        self.add_co_driver driver
      end
    end
    return true
  end

  def remove_co_drivers
    Passenger.where(job_id: self.id).delete_all
  end

  def add_shuttle_breakpoint count
    self.shuttle_data["stops"].insert( count , {:address_id => nil} )
    self.shuttle_data["legs"].insert( count + 1, {:driver_ids => self.shuttle_data["legs"][count]["driver_ids"], :distance => "" } )
    self.save
  end

  def remove_shuttle_breakpoint count
    self.shuttle_data["stops"].delete_at( count )
    self.shuttle_data["legs"].delete_at( count + 1 )
    self.save
  end

  def change_breakpoint_distance distance, count
    if count.is_a? Integer
      self.shuttle_data["legs"][count]["distance"] = distance
    elsif count == "END"
      puts "END DISTANCE"
      puts distance
      puts self.shuttle_data
      self.mileage_delivery = distance
    elsif count == "START"
      self.mileage_collection = distance
    else
      return "Nur Zahlen erlaubt"
    end

    self.save
  end

  def change_breakpoint_address address, count
    logger.info address.inspect
    logger.info count
    if count == 0
      self.from_id = address.id
    elsif count == self.legs.length
      self.to_id = address.id
    else
      self.shuttle_data["stops"][count - 1]["address_id"] = address.id
    end
    self.save
    logger.info "================"
    logger.info self.inspect
    logger.info "================"
  end

  def add_shuttle_passenger passenger, count
    self.shuttle_data["legs"][count]["driver_ids"] << passenger.id
    self.shuttle_data["legs"][count]["driver_ids"].uniq!
    Passenger.where(job:self, driver:passenger).first_or_create
    self.save
  end

  def remove_shuttle_passenger passenger, count
    self.shuttle_data["legs"][count]["driver_ids"].delete( passenger.id )
    unless self.driver_in_shuttle? passenger
      Passenger.where(job:self, driver:passenger).destroy_all
    end
    self.save
  end

  def driver_in_shuttle? driver
    self.legs.each do |leg|
      if leg.driver_ids.include? driver.id
        return true
      end
    end
    return false
  end

  def shuttle_stops_distance
    mileage_stops = 0
    self.shuttle_data["legs"].each do |leg|
      mileage_stops += leg["distance"].to_i
    end
    return mileage_stops
  end

  def get_shuttle_milage_calculation
    milage_complete = self.distance
    mileage_stops = self.shuttle_stops_distance
    return ( milage_complete - mileage_stops ).to_s
  end

  def self.save_many jobs
    unless jobs.empty?
      transaction do
        success = jobs.map(&:save)
        unless success.all?
          errored = jobs.select{|b| !b.errors.blank?}
          # do something with the errored values
          raise ActiveRecord::Rollback
          return false
        end
      end
    end
    return true
  end

  def co_drivers
    co_drivers = []
    unless self.is_shuttle?
      self.passengers.each do |passenger|
        co_drivers << passenger.driver
      end
    end
    co_drivers
  end

  def has_co_drivers?
    !self.passengers.empty? && !self.is_shuttle?
  end

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

  def number_of_drivers
    return self.passengers.length + 1 # Plus 1 for the driver himself
  end

  def price_driver
    if self.final_calculation_basis == Route::FLAT_RATE
      price = self.bill.driver_price_flat_rate
    elsif self.final_calculation_basis == Route::PAY_PER_KM
      price = self.distance * self.bill.driver_price_per_km
    else
      return false
    end
    return price / self.number_of_drivers
  end

  def remove_shuttles
    self.shuttle_data = nil
    self.save
  end

  def delete
    self.status = DELETED
    self.save
  end

  def breakpoints
    if self.shuttle_data.is_a? Hash
      breakpoints = self.shuttle_data["breakpoints"]
    else
      return []
    end
  end

  def legs
    get_shuttle_data.legs
  end

  def stops
    get_shuttle_data.stops
  end

  def price_driver_shuttle( driver_job, get_array = false )
    breakpoints_array = []
    price = 0
    self.legs.each_with_index do |leg, i|
      drivers_in_car = leg.driver_ids.length
      part_price = (( self.bill.driver_price_per_km * leg.distance )/ drivers_in_car )
      price += part_price
      if get_array
        stops = self.stops
        breakpoints_array << [ Address.find_by(id: stops[i].address_id).address_short, Address.find_by(id: stops[i + 1].address_id).address_short, leg.distance, drivers_in_car, part_price ]
      end
    end

    if get_array
      return breakpoints_array
    else
      return price
    end
  end

  def price_sixt_current( sixt = Company.sixt )
    if self.route.calculation_basis == Route::FLAT_RATE
      price = sixt.price_flat_rate
    elsif self.route.calculation_basis == Route::PAY_PER_KM
      price = self.distance * sixt.price_per_km
    else
      return false
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
    if self.driver.nil? || self.is_shuttle?
      error = html_escape ( I18n.translate("jobs.not_billed_no_driver") + self.id.to_s ).encode("ISO-8859-1")
      return error
    end

    if self.is_shuttle? && self.check_legs
      error = html_escape ( I18n.translate("jobs.not_billed_no_driver") + self.id.to_s ).encode("ISO-8859-1")
      return error
    end

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
      if self.stops.empty? && self.shuttle_stops_distance != self.distance
        error = html_escape ( I18n.t("jobs.not_billed_breakpoints_not_correct") + self.id.to_s ).encode("ISO-8859-1")
        return error
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

  def is_shuttle?
    return self.shuttle
  end

  def get_shuttle_data
    data = self.shuttle_data.deep_dup || {:stops=>[], :legs=>[]}
    data["stops"].unshift({:address_id=>self.from_id})
    data["stops"] << {:address_id=>self.to_id}
    data_struct = RecursiveOpenStruct.new(data, recurse_over_arrays: true )
    return data_struct
  end

  def get_shuttle_string
    shuttle_string = ""
    if self.is_shuttle?
      shuttle_string = I18n.t("jobs.shuttle_for_drivers")
      self.passengers.each do |passenger|
        if passenger == self.passengers.last
          shuttle_string += " #{passenger.id}"
        else
          shuttle_string += " #{passenger.id},"
        end
      end
    end
    return shuttle_string
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
