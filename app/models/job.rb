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
    unless self.is_shuttle?
      self.remove_co_drivers
      if !co_driver_ids.nil? && co_driver_ids.is_a?( Array )
        co_driver_ids.each do |co_driver_id|
          driver = Driver.find_by(id: co_driver_id)
          self.add_co_driver driver
        end
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
      self.shuttle_data["legs"][count]["distance"] = distance unless self.shuttle_data["legs"][count].nil?
    elsif count == "END"
      self.mileage_delivery = distance
    elsif count == "START"
      self.mileage_collection = distance
    else
      return "Nur Zahlen erlaubt"
    end

    self.save
  end

  def change_breakpoint_address address, count
    logger.info "change_breakpoint_address"
    logger.info count
    logger.info address
    if count == 0
      self.from_id = address.id
    elsif count == self.legs.length
      self.to_id = address.id
    else
      self.shuttle_data["stops"][count - 1]["address_id"] = address.id
    end
    # self.set_route
    self.save
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

  def drivers_in_shuttle
    driver_ids = []
    drivers = []
    if self.is_shuttle?
      self.legs.each do |leg|
        driver_ids << leg.driver_ids
      end
      driver_ids.flatten
      driver_ids.each do |driver_id|
        driver = Driver.where( id: driver_id )
        drivers << driver unless driver.nil?
      end
      return drivers.uniq
    end
    return drivers
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
    if self.is_shuttle?
      mileage_stops = 0
      if self.shuttle_data.is_a?( Hash ) && self.shuttle_data["legs"].is_a?( Array )
        self.shuttle_data["legs"].each do |leg|
          mileage_stops += leg["distance"].to_i
        end
      end
      return mileage_stops
    else
      return 0
    end
  end

  def get_shuttle_milage_calculation
    if self.is_shuttle?
      milage_complete = self.distance
      mileage_stops = self.shuttle_stops_distance
      return ( milage_complete - mileage_stops ).to_s
    else
      return 0
    end
  end

  def get_route_string
    route_string = ""
    self.stops.each_with_index do |stop, i|
      stop_address = Address.where( id: stop.address_id ).first
      route_string += stop_address.city.to_s
      unless i + 1 == self.stops.length
        route_string += " - "
      end
    end
    return route_string
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
    if self.is_shuttle?
      self.route = nil
      self.save
    else
      unless self.from_id.nil? || self.to_id.nil?
        self.route_id = Route.find_or_create( self.from_id , self.to_id )
        self.save
      else
        return false
      end
    end
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
    get_shuttle_data.legs if self.is_shuttle?
  end

  def stops
    get_shuttle_data.stops if self.is_shuttle?
  end

  def price_driver_shuttle( driver, get_array = false )
    breakpoints_array = []
    price = 0

    self.legs.each_with_index do |leg, i|
      if leg.driver_ids.include?(driver.id)
        drivers_in_car = leg.driver_ids.length
        part_price = (( self.bill.driver_price_per_km * leg.distance )/ drivers_in_car )
        price += part_price
        if get_array
          stops = self.stops
          breakpoints_array << [ Address.find_by(id: stops[i].address_id).show_address, Address.find_by(id: stops[i + 1].address_id).show_address, leg.distance, drivers_in_car, part_price ]
        end
      end
    end

    if get_array
      return breakpoints_array
    else
      return price
    end
  end

  def driver_legs driver
    legs_driver_in_shuttle = []
    self.legs.each_with_index do |leg, i|
      legs_driver_in_shuttle << i + 1 if leg.driver_ids.include? driver.id
    end
    return legs_driver_in_shuttle
  end

  def price_sixt_current( sixt = Company.sixt )
    if self.is_shuttle?
      calculation_basis = Route::PAY_PER_KM
    else
      calculation_basis = self.route.calculation_basis
    end

    if calculation_basis == Route::FLAT_RATE
      price = sixt.price_flat_rate
    elsif calculation_basis == Route::PAY_PER_KM
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

  def check_legs
    return self.get_shuttle_milage_calculation.to_i == 0
  end

  def check_for_billing
    if self.driver.nil? && !self.is_shuttle?
      error = html_escape ( I18n.translate("jobs.not_billed_no_driver") + self.id.to_s ).encode("ISO-8859-1")
      return error
    end

    if self.is_shuttle? && !self.check_legs
      error = html_escape ( I18n.translate("jobs.not_billed_wrong_distance") + self.id.to_s ).encode("ISO-8859-1")
      return error
    end

    ret = self.set_route if self.route.nil?
    return "Addressen nicht korrekt gesetzt. Auftrag nicht verrechnet Auftrag #{self.id}"  if ret == false

    if !self.is_shuttle? && !self.route.is_active?
      error = "Route ist noch nicht gesetzt. Auftrag nicht verrechnet. Auftrag #{self.id}"
      return error
    end

    if !self.is_shuttle? && ( self.mileage_collection.to_i <= 0 || self.mileage_delivery.to_i <= 0 )
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

  def set_shuttle
    self.shuttle = true
    driver_ids = []
    unless self.passengers.empty?
      self.passengers.each do |passenger|
        driver_ids << passenger.driver.id
      end
    end
    unless self.driver_id.nil?
      driver_ids << driver_id
      Passenger.create(job:self, driver_id:driver_id)
    end
    self.shuttle_data = {"stops"=>[], "legs"=>[{distance: self.distance , driver_ids: driver_ids}]}
    self.driver_id = nil
    self.save
  end

  def unset_shuttle
    self.shuttle = false
    passengers = Passenger.where(job:self)
    unless passengers.empty?
      self.driver = passengers.first.driver
      passengers.first.destroy
    end
    self.remove_shuttles
    self.save
  end

  def set_passengers
    self.drivers_in_shuttle.each do |driver|
      Passenger.first_or_create( job: self, driver: driver )
    end
    return true
  end

  def get_shuttle_data
    return nil unless self.is_shuttle?
    data = self.shuttle_data.deep_dup || {"stops"=>[], "legs"=>[{distance:0, driver_ids:[]}]}
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
          shuttle_string += " #{passenger.driver.id}"
        else
          shuttle_string += " #{passenger.driver.id},"
        end
      end
    end
    return shuttle_string
  end

  def distance_string
    if self.is_shuttle?
      return "Shuttle"
    else
      return self.route.is_flat_rate? ? "Pauschale" : self.route.distance.to_s
    end
  end

  def charged?
    self.status == CHARGED
  end

  def apply_shuttle_car_data shuttle_car
    self.registration_number = shuttle_car.registration_number
    self.car_type = shuttle_car.car_type
    self.car_brand = shuttle_car.car_brand
    self.save
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
