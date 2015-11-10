class DeleteDoubleAdresses < ActiveRecord::Migration
  def change
    uniq_addresses = []
    double_addresses = []
    Address.all.each do |address|
      adr_hash = {address: address.address, address_short: address.address_short, zip_code: address.zip_code, city: address.city, country: address.country }
      if uniq_addresses.include? adr_hash
        double_addresses << adr_hash
      else
        uniq_addresses << adr_hash
      end
    end
    double_addresses.each do |double_address|
      multi = Address.where(address: double_address[:address], address_short: double_address[:address_short], zip_code: double_address[:zip_code], city: double_address[:city], country: double_address[:country])
      to_remove = multi.last
      confict_jobs = Job.where("from_id = #{to_remove.id} or to_id = #{to_remove.id}")
      if confict_jobs.nil?
        to_remove.destroy
        puts "removed Address #{to_remove.id}"
      else
        to_remove = multi.first
        confict_jobs = Job.where("from_id = #{to_remove.id} or to_id = #{to_remove.id}")
        if confict_jobs.nil?
          to_remove.destroy
          puts "removed Address #{to_remove.id} because conficts"
        else
          puts "could not remove #{multi.first.id} or #{multi.last.id}"
        end
      end
    end
  end
end
