class RemoveWrongRoutes < ActiveRecord::Migration
  def change
    i=1
    Route.get_new.each do |route|
      route.destroy
      i+=1
    end
    puts "#{i} Routen entfernt"
    i=1
    Job.get_open.each do |job|
      job.set_route
      i+=1
    end
    puts "Bei #{i} Jobs Route gesetzt"
  end
end
