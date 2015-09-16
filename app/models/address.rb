class Address < ActiveRecord::Base
  paginates_per 10
  def self.get_active
    Address.where( inactive: false )
  end
end
