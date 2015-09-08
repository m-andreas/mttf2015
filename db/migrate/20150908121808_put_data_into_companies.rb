class PutDataIntoCompanies < ActiveRecord::Migration
  def up
    c = Company.new
    c.id = 1
    c.name = "MT Trans-Fair GmbH"
    c.address = "Ortsstrasse 18b"
    c.zip_code = "2331"
    c.email = "office@mt-transfair.at"
    c.city = "Vösendorf"
    c.country = "Österreich"
    c.price_per_km = 0
    c.price_flat_rate = 0
    c.telephone = "01/6992010"
    c.save

    c = Company.new
    c.id = 2
    c.name = "SIXT GmbH"
    c.address = "Ortsstrasse 18a"
    c.zip_code = "2331"
    c.email = "michael.schneider@sixt.com"
    c.city = "Vösendorf"
    c.country = "Österreich"
    c.price_per_km = 0.24
    c.price_flat_rate = 19
    c.telephone = "01/5052640"
    c.save    
  end

  def down
    Company.delete_all
  end
end
