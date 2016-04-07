class JobsAllDatatable
  delegate :params, :h, :link_to, :fa_icon, :button_to, to: :@view
  include Rails.application.routes.url_helpers

  def initialize(view)
    @view = view
    @job = Job.includes(:driver).find(params[:main_job_id]) unless params[:main_job_id] == ""
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
        fullname = job.driver.nil? ? "" : job.driver.fullname_id
        from_address_short = job.from.nil? ? "" : job.from.address_short
        to_address_short = job.to.nil? ? "" : job.to.address_short
        icon = link_to( fa_icon( "bus", text:  "Shuttle erzeugen" ),  "#{ENV['URL_PREFIX']}jobs/change_to_shuttle/#{job.id}")

        created_at = job.created_at.nil? ? "" : job.created_at.strftime("%e.%-m.%Y")

        job = [
          job.id,
          icon,
          job.id,
          fullname,
          from_address_short,
          to_address_short,
          created_at
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
    records = Job.where( status: [Job::OPEN, Job::FINISHED], shuttle: false ).order("#{sort_column} #{sort_direction}")

    if params[:search][:value].present?
      search = params[:search][:value].strip
      records = records.where("id like :search or registration_number like :search", search: "%#{search}%")
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
    columns = %w[JOBS.ID JOBS.ID JOBS.ID JOBS.ID JOBS.ID JOBS.ID]
    columns[params[:order][:'0'][:column].to_i]
  end

  def sort_direction
    params[:order][:'0'][:dir] == "desc" ? "desc" : "asc"
  end
end
