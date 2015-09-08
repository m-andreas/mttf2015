class PutDataToRoutes < ActiveRecord::Migration
  def up
   i = 1
    StKMTabelleNeu.find_each(batch_size: 1000) do |km|
      route = Route.new
      route.id = km.id
      route.from_id = km.VonID unless km.VonID == 0
      route.to_id = km.NachID unless km.NachID == 0
      route.calculation_basis = km.FaStatus
      route.distance = km.KM
      route.status = km.Edit
      route.save
      if i % 100 == 0
        puts "Processed #{i} addresses"
      end
      i += 1
    end
  end

  def down
    i=1
    Routes.find_each(batch_size: 2000) do |route|
      route.destroy
      if i % 100 == 0
        puts "Deleted #{i} routes"
      end
      i += 1
    end
  end
end
