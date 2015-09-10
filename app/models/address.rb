class Address < ActiveRecord::Base
  def self.get_active
    Address.where( inactive: false )
  end
end
