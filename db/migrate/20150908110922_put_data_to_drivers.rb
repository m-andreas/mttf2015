class PutDataToDrivers < ActiveRecord::Migration
  def up
   i = 1
    StFahrer.find_each(batch_size: 1000) do |fahrer|
      driver = Driver.new
      driver.id = fahrer.id
      driver.first_name = fahrer.Vorname.to_s.strip
      driver.last_name = fahrer.Nachname.to_s.strip
      driver.entry_date = fahrer.Eintritt
      driver.exit_date = fahrer.Austritt
      driver.date_of_birth = fahrer.GebDatum
      driver.place_of_birth = fahrer.GebOrt.to_s.strip
      driver.address = fahrer.Adresse.to_s.strip
      driver.city = fahrer.Ort.to_s.strip
      driver.zip_code = fahrer.PLZ.to_s.strip
      driver.telepone = fahrer.TelNR1.to_s.strip
      driver.telephone2 = fahrer.TelNr2.to_s.strip
      driver.licence_number = fahrer.FS_Nummer.to_s.strip
      driver.issuing_authority = fahrer.FS_Ausstellungsb.to_s.strip
      driver.driving_licence_category = fahrer.FS_Klassen.to_s.strip
      driver.comment = fahrer.Bemerkungen.to_s.strip
      driver.social_security_number = fahrer.SVNummer.to_s.strip
      driver.driving_licence_copy = fahrer.FSKopie
      driver.registration_copy = fahrer.MeldzettelKopie
      driver.service_contract = fahrer.Werkvertrag
      driver.save
      if i % 100 == 0
        puts "Created #{i} drivers"
      end
      i += 1
    end
  end

  def down
    i=1
    Driver.find_each(batch_size: 2000) do |driver|
      driver.destroy
      if i % 100 == 0
        puts "Deleted #{i} drivers"
      end
      i += 1
    end
  end  
end
