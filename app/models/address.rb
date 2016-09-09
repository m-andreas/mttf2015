class Address < ActiveRecord::Base
  paginates_per 10
  def self.get_active
    Address.where( inactive: false ).order(:address_short)
  end

  def complete_address
    complete_address = self.show_address.to_s
    complete_address = complete_address + ", " + self.address.to_s unless self.address.to_s.gsub(",","").gsub(".","").strip.empty?
    add_info =  self.zip_code.to_s + " " + self.city.to_s + " " + self.country.to_s
    complete_address = complete_address + " " + add_info unless add_info.gsub(",","").gsub(".","").strip.empty?
    return complete_address
  end

  def self.find_or_get( address_id )
    from = Address.find_by_id( address_id )
    if from.nil?
      foreign_address = Adressenpool.find_by_id( auftrag.UeberstellungVon )
      if foreign_address.nil?
        return nil
      else
        address = Address.new
        address.id = foreign_address.id
        address.created_by = foreign_address.LoginID unless foreign_address.LoginID == 0
        address.country = foreign_address.Land.strip unless foreign_address.Land.nil?
        address.city = foreign_address.Ort.strip unless foreign_address.Land.nil?
        address.zip_code = foreign_address.PLZ.to_s.strip
        address.address = foreign_address.Adresse.strip unless foreign_address.Adresse.nil?
        address.address_short = foreign_address.Kurzadresse.strip unless foreign_address.Kurzadresse.nil?
        address.inactive = foreign_address.deaktiviert
        address.save
        return address
      end
    else
      return from
    end
  end


  def show_address
    if self.display_name.to_s.empty?
      address = self.address_short.to_s
    else
      address = self.display_name.to_s
    end
    if address.empty?
      address = self.city.to_s
    end
    return address
  end
end
