class PutDataToAddresses < ActiveRecord::Migration
  def up
   i = 1
    Adressenpool.find_each(batch_size: 1000) do |adresse|
      address = Address.new
      address.id = adresse.id
      address.created_by = adresse.LoginID unless adresse.LoginID == 0
      address.country = adresse.Land.strip unless adresse.Land.nil? 
      address.city = adresse.Ort.strip unless adresse.Land.nil?
      address.zip_code = adresse.PLZ.to_s.strip
      address.address = adresse.Adresse.strip unless adresse.Adresse.nil?
      address.address_short = adresse.Kurzadresse.strip unless adresse.Kurzadresse.nil?
      address.inactive = adresse.deaktiviert
      address.save
      if i % 100 == 0
        puts "Processed #{i} addresses"
      end
      i += 1
    end
  end

  def down
    i=1
    Address.find_each(batch_size: 2000) do |address|
      address.destroy
      if i % 1000 == 0
        puts "Deleted #{i} addresses"
      end
      i += 1
    end
  end
end
