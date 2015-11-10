class Driver < ActiveRecord::Base
  has_many :carriers
  has_many :jobs, through: :carriers
  paginates_per 10
  def self.get_active
    now = DateTime.now
    where('(exit_date > ? OR exit_date IS NULL) AND entry_date <= ? AND deleted = ?', now, now, false)
  end

  def fullname
    self.firstname + " " + self.lastname
  end

  def fullname_id
    self.fullname + " (" + self.id.to_s + ")"
  end

  def firstname
    self.first_name
  end

  def lastname
    self.last_name
  end
end
