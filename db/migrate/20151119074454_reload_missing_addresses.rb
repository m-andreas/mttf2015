class ReloadMissingAddresses < ActiveRecord::Migration
  def up
    Adressenpool.where.not(AdressenpoolID: Address.all.pluck(:id)).each do |adresse|
      address = Address.new
      address.id = adresse.id
      address.created_by = adresse.LoginID unless adresse.LoginID == 0
      address.country = adresse.Land.strip unless adresse.Land.nil?
      address.city = adresse.Ort.strip unless adresse.Land.nil?
      address.zip_code = adresse.PLZ.to_s.strip
      address.address = adresse.Adresse.strip unless adresse.Adresse.nil?
      address.address_short = adresse.Kurzadresse.strip unless adresse.Kurzadresse.nil?
      address.inactive = adresse.deaktiviert
      address.save!
      puts address.id
    end
  end

  def down
  end
end
