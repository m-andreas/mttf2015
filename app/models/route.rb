class Route < ActiveRecord::Base
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"
  paginates_per 10

  NEW = 0
  PROCESSED = 1
  DELETED = 2

  FLAT_RATE = 1
  PAY_PER_KM = 2

  def self.get_active
    where( "status in (:show)", show: [ NEW, PROCESSED ] ).includes( :from, :to )
  end

  def self.find_or_create( from_id, to_id)
    route = find_by( from_id: from_id, to_id: to_id )
    if route.nil?
      route = Route.create(
        from_id: from_id,
        to_id: to_id,
        status: NEW
      )
    end
    route.set_new if route.is_deleted?
    return route.id
  end

  def self.get_calculation_bases
    return [ [ FLAT_RATE, "Pauschale" ] , [ PAY_PER_KM, "Per Kilometer" ] ]
  end

  def is_active?
    self.status == PROCESSED
  end

  def is_new?
    self.status == NEW
  end

  def set_new
    self.status = NEW
    self.save!
  end

  def set_processed
    self.status = PROCESSED
    self.save!
  end

  def is_deleted?
    self.status == DELETED
  end

  def self.count_new
    where( status: NEW ).count
  end

  def self.get_new
    where( status: Route::NEW ).includes( :from, :to )
  end

  def get_calculation_basis
    case self.calculation_basis
    when FLAT_RATE
      return "Pauschale"
    when PAY_PER_KM
      return "Per Kilometer"
    else
      return "unbekannt"
    end
  end

  def get_status
    case self.status
    when NEW
      return "Neu"
    when PROCESSED
      return "Aktuell"
    when DELETED
      return "Gelöscht"
    else
      return "Unbekannt"
    end
  end
end
