class Driver < ActiveRecord::Base
  has_many :carriers
  has_many :jobs, through: :carriers
  
  def self.get_active
    now = DateTime.now
    where('(exit_date > ? OR exit_date IS NULL) AND entry_date <= ?', now, now)
  end

  def fullname
    firstname + " " + lastname
  end

  def firstname
    first_name
  end

  def lastname
    last_name
  end
end
