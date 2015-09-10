class PutDataIntoCarriers < ActiveRecord::Migration
  def create_carrier ( driver_id, job_id, chauffeur)
      carrier = Carrier.new
      carrier.driver_id = driver_id
      carrier.job_id = job_id
      carrier.chauffeur = chauffeur
      carrier.save!
  end

  def change
    i = 1
    Fahrtauftrag.find_each(batch_size: 1000) do |auftrag|  
      create_carrier( auftrag.FahrerID, auftrag.id, true )
      create_carrier( auftrag.BFahrerID1, auftrag.id, false ) unless auftrag.BFahrerID1.nil? || auftrag.BFahrerID1 == 0 || auftrag.to_s.strip.empty?
      create_carrier( auftrag.BFahrerID2, auftrag.id, false ) unless auftrag.BFahrerID2.nil? || auftrag.BFahrerID2 == 0 || auftrag.to_s.strip.empty?
      create_carrier( auftrag.BFahrerID3, auftrag.id, false ) unless auftrag.BFahrerID3.nil? || auftrag.BFahrerID3 == 0 || auftrag.to_s.strip.empty?
      create_carrier( auftrag.BFahrerID4, auftrag.id, false ) unless auftrag.BFahrerID4.nil? || auftrag.BFahrerID4 == 0 || auftrag.to_s.strip.empty?
      create_carrier( auftrag.BFahrerID5, auftrag.id, false ) unless auftrag.BFahrerID5.nil? || auftrag.BFahrerID5 == 0 || auftrag.to_s.strip.empty?
      create_carrier( auftrag.BFahrerID6, auftrag.id, false ) unless auftrag.BFahrerID6.nil? || auftrag.BFahrerID6 == 0 || auftrag.to_s.strip.empty?
      create_carrier( auftrag.BFahrerID7, auftrag.id, false ) unless auftrag.BFahrerID7.nil? || auftrag.BFahrerID7 == 0 || auftrag.to_s.strip.empty?
      create_carrier( auftrag.BFahrerID8, auftrag.id, false ) unless auftrag.BFahrerID8.nil? || auftrag.BFahrerID8 == 0 || auftrag.to_s.strip.empty?
      if i % 1000 == 0
        puts "Processed #{i} Jobs"
      end
      i += 1
    end
  end

  def down
    i=1
    Carrier.find_each(batch_size: 2000) do |carrier|
      carrier.destroy
      if i % 1000 == 0
        puts "Deleted #{i} Carriers"
      end
      i += 1
    end
  end
end
