class ShuttleDatatable
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
    search = params[:search][:value].strip
    status = []
    status << 1 if params[:show_open] == "true"
    status << 2 if params[:show_finished] == "true"
    status << 3 if params[:show_charged] == "true"
    records = records.where("shuttle = 1 and status IN (:status) and ( lower(car_brand) like :search or lower(car_type) like :search or lower(registration_number) like :search or lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search )", search: "%#{search}%", status: status)

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