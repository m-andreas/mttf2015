class Bill < ActiveRecord::Base
  has_many :jobs

  require 'csv'

  def self.get_old
    old_bills = Bill.where.not( billed_at: nil ).order(billed_at: :desc)
  end

  def self.get_current_with_includes
    current_bill = where( billed_at: nil ).includes( :jobs )[ 0 ]
    if current_bill.nil?
      current_bill = create
    end
    return current_bill
  end

  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Rechnung fuer #{self.print_date}"]
      csv << [ "ID", "ABHOLUNG", "LIEFERUNG", "NACH", "VON", "KZ", "KM", "", "", "", "", "EUR", "KSt" ]
      self.jobs.each do |job|
        csv << [job.id, job.actual_collection_date, job.actual_delivery_date, job.to.complete_address, job.from.complete_address,
          job.registration_number, job.route.distance, job.distance, "", job.route.get_calculation_basis, "", job.price_sixt, job.cost_center_id ]
      end
      csv << []
      csv << [ "", "", "", "", "", "", "", "", "", "", "Gesamt",sixt_total]
    end
  end

  def self.get_current
    current_bill = Bill.where( billed_at: nil )[ 0 ]
    if current_bill.nil?
      current_bill = Bill.create
    end
    return current_bill
  end

  def is_current?
    self.billed_at.nil?
  end

  def is_old?
    !self.billed_at.nil?
  end

  def add_jobs jobs
    messages = []
    jobs.each do |job|
      msg = job.check_for_billing
      if msg == true
        job.set_billed( self )
      else
        messages << msg
      end
    end
    if messages.empty?
      return true
    else
      return messages
    end
  end

  def drivers
    drivers_in_bill = []
    self.jobs.each do |job|
      drivers_in_bill << job.driver
      if job.has_co_drivers?
        job.co_drivers.each do |co_driver|
          drivers_in_bill << co_driver
        end
      end
    end
    drivers_in_bill.uniq!
    return drivers_in_bill
  end

  def get_main_drives_array( driver )
    jobs = self.jobs.where( driver_id: driver.id ).pluck( :id )
    jobs += Passenger.where(driver_id: driver.id, job_id: self.jobs).pluck(:job_id)
    return jobs
  end

  def get_main_drives( driver )
    jobs = self.jobs.where( driver_id: driver.id )
    Passenger.where(driver_id: driver.id, job_id: self.jobs).each do |passenger|
      jobs << passenger.job
    end
    return jobs
  end

  def get_jobs_array( driver )
    main_jobs = self.get_main_drives_array( driver )
    return main_jobs | Carrier.where( co_job_id: main_jobs ).pluck( :job_id )
  end

  def job_price( job, driver )
    if job.shuttle?
      if job.driver != driver
        driver_job = Carrier.find_by( co_job_id: self.get_main_drives_array( driver ), job_id: job.id ).co_job
      else
        driver_job = job
      end
      price = job.price_driver_shuttle( driver_job )
    else
      price = job.price_driver
    end
    return price
  end

  def driver_total( driver )
    total = 0
    job_ids = self.get_jobs_array( driver )
    jobs = Job.find(job_ids)
    jobs.each do |job|
      job_price = job_price( job, driver )
      return false unless job_price
      total += job_price
    end
    return total
  end

  def sixt_total
    total = 0
    self.jobs.each do |job|
      job_price = job.price_sixt
      return false unless job_price
      total += job_price
    end
    return total
  end

  def pay
    self.price_flat_rate = Company.sixt.price_flat_rate
    self.driver_price_flat_rate = Company.transfair.price_flat_rate
    self.price_per_km = Company.sixt.price_per_km
    self.driver_price_per_km = Company.transfair.price_per_km
    missing_dependencys = []
    self.jobs.each do |job|
      missing_dependencys << job.check_shuttle_dependencies
    end

    missing_dependencys.flatten!
    if missing_dependencys.empty?
      self.billed_at = DateTime.now
      self.save
      self.jobs.each do |job|
        job.final_calculation_basis = job.route.calculation_basis
        job.set_charged
      end
      return true
    else
      return missing_dependencys
    end
  end
end
