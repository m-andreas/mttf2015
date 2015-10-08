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
      csv << [ "Id", "Preis" ]
      self.jobs.each do |job|
        csv << [job.id, job.price]
      end
      csv << ["Gesamt",sixt_total]
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

  def sixt_total
    total = 0
    self.jobs.each do |job|
      total += job.price
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
        job.final_distance = job.route.distance
        job.final_calculation_basis = job.route.calculation_basis
        job.set_charged
      end
      return true
    else
      return missing_dependencys
    end
  end
end
