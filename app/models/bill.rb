class Bill < ActiveRecord::Base
  has_many :jobs

  def self.get_old
    old_bills = Bill.where.not( billed_at: nil )
  end

  def self.get_current_with_includes
    current_bill = where( billed_at: nil ).includes( :jobs )[ 0 ]
    if current_bill.nil?
      current_bill = create
    end
    return current_bill
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
    jobs.each do |job|
      job.set_billed( self )
    end
  end

  def pay
    self.billed_at = DateTime.now
    self.jobs.each do |job|
      job.set_charged
    end
    self.save
  end
end
