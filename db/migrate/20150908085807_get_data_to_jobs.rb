class GetDataToJobs < ActiveRecord::Migration
  def up
#    i = 1
#    Fahrtauftrag.where( "InsertDate >= Convert( datetime, '2015-06-01' )" ).find_each(batch_size: 1000) do |auftrag|
#      job = Job.new
#      job.id = auftrag.id
#      job.customer_job_id = auftrag.KundenauftragID
#      driver_ids = [ auftrag.FahrerID ]
#      driver_ids << auftrag.BFahrerID1 unless auftrag.BFahrerID1.nil? || auftrag.BFahrerID1 == 0
#      driver_ids << auftrag.BFahrerID2 unless auftrag.BFahrerID2.nil? || auftrag.BFahrerID2 == 0
#      driver_ids << auftrag.BFahrerID3 unless auftrag.BFahrerID3.nil? || auftrag.BFahrerID3 == 0
#      driver_ids << auftrag.BFahrerID4 unless auftrag.BFahrerID4.nil? || auftrag.BFahrerID4 == 0
#      driver_ids << auftrag.BFahrerID5 unless auftrag.BFahrerID5.nil? || auftrag.BFahrerID5 == 0
 #     driver_ids << auftrag.BFahrerID6 unless auftrag.BFahrerID6.nil? || auftrag.BFahrerID6 == 0
#      driver_ids << auftrag.BFahrerID7 unless auftrag.BFahrerID7.nil? || auftrag.BFahrerID7 == 0
#      driver_ids << auftrag.BFahrerID8 unless auftrag.BFahrerID8.nil? || auftrag.BFahrerID8 == 0
#      job.driver_ids = driver_ids
#      job.mvn = auftrag.MVN.strip unless auftrag.MVN.nil?
#      job.cost_center_id = auftrag.KostenstelleID
#      job.finished = auftrag.Status
#      job.from_id = auftrag.UeberstellungVon
#      job.to_id = auftrag.UeberstellungNach
#      job.shuttle = auftrag.Shuttelfahrt
#      #job.times_printed = auftrag.AnzahlAusdrücke
#      job.car_brand = auftrag.AutoMarke.strip unless auftrag.AutoMarke.nil?
#      job.car_type = auftrag.AutoType.strip unless auftrag.AutoType.nil?
#      job.registration_number = auftrag.Kennzeichen.strip unless auftrag.Kennzeichen.nil?
#      job.chassis_number = auftrag.FgNr.strip unless auftrag.FgNr.nil?
#      job.job_notice = auftrag.AuftragsBemerkungen.strip unless auftrag.AuftragsBemerkungen.nil?
#      job.transport_notice = auftrag.TransportBemerkungen.strip unless auftrag.TransportBemerkungen.nil?
#      job.transport_notice_extern = auftrag.TransportBemerkungenExtern.strip unless auftrag.TransportBemerkungenExtern.nil?
#      job.scheduled_collection_date = auftrag.GeplantesTransportDatumAbholung
#      job.scheduled_delivery_date = auftrag.GeplanteTransportDatumAbgabe
#      job.actual_collection_date = auftrag.RealesAbholDatum
#      job.actual_delivery_date = auftrag.RealesAbgabeDatum
#      job.mileage_collection = auftrag.TachostandKMRealAbholung
#      job.mileage_delivery = auftrag.TachostandKMRealAbgabe
#      job.price_extern = auftrag.TransportKostExt
#      job.created_at = auftrag.InsertDate
#      job.updated_at = auftrag.InsertDate
#      job.duplicate = auftrag.IsDuplicate
#      job.save
#      if i % 1000 == 0
#        puts "Processed #{i} Jobs"
#      end
#      i += 1
#    end
  end

  def down
#    i=1
#    Job.find_each(batch_size: 2000) do |job|
#      job.destroy
#      if i % 1000 == 0
#        puts "Deleted #{i} Jobs"
#      end
#      i += 1
    end
  end
end
