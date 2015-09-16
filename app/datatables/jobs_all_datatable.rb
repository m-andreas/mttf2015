class JobsAllDatatable
  delegate :params, :h, :link_to, :fa_icon,  to: :@view
  include Rails.application.routes.url_helpers

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      data: data, 
      recordsTotal: my_search.count, 
      recordsFiltered: sort_order_filter.count 
    }
  end

private

  def data
    jobs = [] 

    display_on_page.map do |job|
      puts job.inspect
      if job.nil?
        puts job.inspect
      else
        fullname = job.driver.nil? ? "" : job.driver.fullname
        from_address_short = job.from.nil? ? "" : job.from.address_short 
        to_address_short = job.to.nil? ? "" : job.to.address_short 
        icon = fa_icon "user-plus", text: "hinzufügen"
        shuttle = job.is_shuttle? ? "Ja" : "Nein"
        edit = link_to 'Editieren', edit_job_path(job)
        show = link_to 'Anzeigen', job_path(job)
        if job.actual_collection_date.nil?
          if job.scheduled_collection_date.nil?
            collection_date = ""
          else
            collection_date = job.scheduled_collection_date.strftime("%e.%-m.%Y")
          end
        else
          collection_date = job.actual_collection_date.strftime("%e.%-m.%Y")
        end

        if job.actual_delivery_date.nil?
          if job.scheduled_delivery_date.nil?
            delivery_date = ""
          else
            delivery_date = job.scheduled_delivery_date.strftime("%e.%-m.%Y")
          end
        else
          delivery_date = job.actual_delivery_date.strftime("%e.%-m.%Y")
        end

        job = [
          job.id,
          fullname,
          job.registration_number,
          collection_date,
          delivery_date,
          from_address_short,
          to_address_short,
          shuttle,
          edit,
          show
        ]
        jobs << job
      end
    end
    jobs
  end

  def my_search 
    @filtered_products = Job.all.includes(:from, :to, :driver)
  end 
  
 def sort_order_filter 
    records = Job.order("#{sort_column} #{sort_direction}").includes( :driver )
    if ( params[:search].present? && params[:search][:value].present? ) || !params[:end_at_date].empty? || !params[:start_from_date].empty?
      search = params[:search][:value].strip
      start_from_date = Date.strptime( params[:start_from_date], "%d.%m.%Y" ) unless params[:start_from_date].empty?
      end_at_date = Date.strptime( params[:end_at_date], "%d.%m.%Y" ) unless params[:end_at_date].empty?
      puts "======================================"
      puts start_from_date
      puts end_at_date
      if start_from_date.nil? && end_at_date.nil?
        puts "1"
        records = records.where("lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search", search: "%#{search}%") 
      elsif start_from_date.nil? && !end_at_date.nil?
        puts "2"
        records = records.where(":end_at_date >= actual_delivery_date and (lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search)", search: "%#{search}%", end_at_date: end_at_date) 
      elsif start_from_date.nil? && end_at_date.nil?
        puts "3"
        records = records.where(":start_from_date <= actual_collection_date and (lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search)", search: "%#{search}%", start_from_date: start_from_date) 
      else
        puts "4"
        records = records.where(":start_from_date <= actual_collection_date and :end_at_date >= actual_delivery_date and (lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search)", search: "%#{search}%", start_from_date: start_from_date, end_at_date: end_at_date) 
      end
    end 
    records 
  end 

  def display_on_page 
    sort_order_filter.page(page).per(per_page) 
  end 

  def page 
    params[:start].to_i/per_page + 1 
  end 

  def per_page 
    params[:length].to_i > 0 ? params[:length].to_i : 10 
  end 

  def sort_column 
    "JOBS.ID"
  end 

  def sort_direction 
    if params[:order].nil?
      "desc"
    else
      params[:order][:'0'][:dir] == "desc" ? "desc" : "asc" 
    end
  end 
end