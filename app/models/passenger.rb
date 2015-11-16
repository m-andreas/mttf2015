class Passenger < ActiveRecord::Base
  belongs_to :job
  belongs_to :driver
end
