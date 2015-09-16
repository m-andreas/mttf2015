class Address < ActiveRecord::Base
  paginates_per 10
  def self.get_active
    Address.where( inactive: false )
  end

  def complete_address
    self.address.to_s + ", " + self.zip_code.to_s + " " + self.city.to_s + " " + self.country.to_s  
  end
end
