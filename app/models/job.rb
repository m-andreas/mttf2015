class Job < ActiveRecord::Base
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"
  has_many :carriers
  has_many :drivers, through: :carriers
  belongs_to :route
  belongs_to :created_by, class_name: "User"

  def driver
    carriers.find_by( :chauffeur => true ).driver
  end

  def co_drivers
    co_drivers = [ ]
    carriers.where( :chauffeur => false ).each do |carrier|
      co_drivers << carrier.driver
    end
    return co_drivers
  end

  def add_driver( driver_id )
    carrier = Carrier.new
    carrier.driver_id = driver_id
    carrier.job_id = self.id
    carrier.chauffeur = true
    return carrier.save
  end
end
