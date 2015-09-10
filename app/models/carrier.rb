class Carrier < ActiveRecord::Base
  belongs_to :driver
  belongs_to :job
end
