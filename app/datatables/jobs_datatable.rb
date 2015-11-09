class JobsDatatable
  delegate :params, :h, :link_to, :fa_icon,  to: :@view

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
      unless job.nil?
        fullname = job.driver.nil? ? "" : link_to( job.driver.fullname, "/mttf2015/drivers/#{job.driver.id}")

        from_address_short = job.from.nil? ? "" : job.from.address_short
        to_address_short = job.to.nil? ? "" : job.to.address_short
        icon = fa_icon "user-plus", text: I18n.translate("add")
        shuttle = job.is_shuttle? ? "Ja" : "Nein"
        if job.is_open?
          edit = link_to 'Editieren', "/mttf2015/jobs/#{job.id}/edit"
          add_to_current = link_to "verrechnen", "/mttf2015/jobs/add_to_current_bill/#{job.id}", method: :post, remote: true
          delete = link_to I18n.translate(:delete), "/mttf2015/jobs/delete/#{job.id}", method: :post, data: { confirm: I18n.translate("jobs.really_delete") }, remote: true
        else
          edit = ""
          add_to_current = ""
          delete = ""
        end
        show = link_to 'Anzeigen', "/mttf2015/jobs/#{job.id}"
        if job.actual_collection_time.nil?
          if job.scheduled_collection_time.nil?
            collection_date = ""
          else
            collection_date = job.scheduled_collection_time.strftime("%e.%-m.%Y")
          end
        else
          collection_date = job.actual_collection_time.strftime("%e.%-m.%Y")
        end

        if job.actual_delivery_time.nil?
          if job.scheduled_delivery_time.nil?
            delivery_date = ""
          else
            delivery_date = job.scheduled_delivery_time.strftime("%e.%-m.%Y")
          end
        else
          delivery_date = job.actual_delivery_time.strftime("%e.%-m.%Y")
        end

        if job.has_shuttle?
          in_shuttle = link_to job.shuttle_job.id, "/mttf2015/jobs/#{job.shuttle_job.id}"
        else
          in_shuttle = "Nein"
        end

        if job.is_shuttle?
          in_shuttle = "Shuttlefahrt"
        end



        job = [
          job.id,
          fullname,
          job.registration_number,
          collection_date,
          delivery_date,
          from_address_short,
          to_address_short,
          in_shuttle,
          edit,
          show,
          delete,
          add_to_current
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
    records = Job.order("#{sort_column} #{sort_direction}").includes(:from, :to, :driver)
    search = params[:search][:value].strip
    start_from_date = Date.strptime( params[:start_from_date], "%d.%m.%Y" ) unless params[:start_from_date].nil? || params[:start_from_date].empty?
    end_at_date = Date.strptime( params[:end_at_date], "%d.%m.%Y" ) unless params[:end_at_date].nil? || params[:end_at_date].empty?
    status = [ ]
    status << 1 if params[:show_open] == "true"
    status << 2 if params[:show_finished] == "true"
    status << 3 if params[:show_charged] == "true"

    shuttle = []
    shuttle << 1 if params[:show_shuttles] == "true"
    shuttle << 0 if params[:show_regular_jobs] == "true"
    if start_from_date.nil? && end_at_date.nil?
      records = records.where("shuttle IN (:shuttle) and status IN (:status) and ( addresses.address_short like :search or tos_jobs.address_short like :search or jobs.id like :search or lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search )", search: "%#{search}%", status: status, shuttle: shuttle)
    elsif start_from_date.nil? && !end_at_date.nil?
      records = records.where("shuttle IN (:shuttle) and status IN (:status) and (( :end_at_date >= cast(actual_collection_time as date) or :end_at_date >= cast(scheduled_collection_time as date)) and (  addresses.address_short like :search or tos_jobs.address_short like :search or jobs.id like :search or lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search))", search: "%#{search}%", end_at_date: end_at_date, status: status, shuttle: shuttle )
    elsif !start_from_date.nil? && end_at_date.nil?
      records = records.where("shuttle IN (:shuttle) and status IN (:status) and (( :start_from_date <= cast(actual_delivery_time as date) or :start_from_date <= cast(scheduled_delivery_time as date)) and (  addresses.address_short like :search or tos_jobs.address_short like :search or jobs.id like :search or lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search))", search: "%#{search}%", start_from_date: start_from_date, status: status, shuttle: shuttle )
    else
      records = records.where("shuttle IN (:shuttle) and status IN (:status) and ((( :start_from_date <= cast(actual_delivery_time as date) and :end_at_date >= CAST(actual_collection_time as date)) or ( :start_from_date <= cast(scheduled_delivery_time as date) and :end_at_date >= CAST(scheduled_collection_time as date))) and (  addresses.address_short like :search or tos_jobs.address_short like :search or jobs.id like :search or lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search))", search: "%#{search}%", start_from_date: start_from_date, end_at_date: end_at_date, status: status, shuttle: shuttle)
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