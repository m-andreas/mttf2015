class Company < ActiveRecord::Base
  TRANSFAIR = 1
  SIXT = 2

  def self.sixt
    find(SIXT)
  end

  def self.transfair
    find(TRANSFAIR)
  end
end
