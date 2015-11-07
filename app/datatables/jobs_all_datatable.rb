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
        fullname = job.driver.nil? ? "" : job.driver.fullname
        from_address_short = job.from.nil? ? "" : job.from.address_short
        to_address_short = job.to.nil? ? "" : job.to.address_short
        if params[ :form_type ] == "edit"
          icon = link_to( fa_icon( "user-plus", text: I18n.translate(:add)), "/mttf2015/jobs/add_co_driver/#{params[:main_job_id]}?co_job_id=#{job.id}", remote: true )
        else
          icon = fa_icon( "user-plus", text:  I18n.translate(:add) )
        end

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
    if @job
      if @job.driver.nil?
        records = Job.includes( :driver ).where( status: [Job::OPEN, Job::FINISHED], shuttle: false ).where.not( id: Carrier.all.pluck(:co_job_id) ).order("#{sort_column} #{sort_direction}")
      else
        # Alle die offen oder in aktueller Abrechnung sind, kein shuttle sind, noch nicht zu einem Shuttle gehoeren und nicht der Fahrer des Shuttels sind
        records = Job.includes( :driver ).where( status: [Job::OPEN, Job::FINISHED], shuttle: false ).where.not( id: Carrier.all.pluck(:co_job_id), drivers: { id: @job.driver.id } ).order("#{sort_column} #{sort_direction}")
      end
    else
      records = Job.includes( :driver ).where( status: [Job::OPEN, Job::FINISHED], shuttle: false ).where.not( id: Carrier.all.pluck(:co_job_id)).order("#{sort_column} #{sort_direction}")
    end

    if params[:search][:value].present?
      search = params[:search][:value].strip
      if search.include?( " " ) && search.split( " " ).length <= 2
        search_spitted = search.split( " " )

        records = records.where("lower(last_name) like :search1 and lower(first_name) like :search2 or lower(first_name) like :search1 and lower(last_name) like :search2", search1: "%#{search_spitted[0]}%", search2: "%#{search_spitted[1]}%")
      else
        records = records.where("lower(last_name) like :search or lower(first_name) like :search or lower(first_name) like :search", search: "%#{search}%")
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
    columns = %w[JOBS.ID JOBS.ID JOBS.ID JOBS.ID JOBS.ID JOBS.ID]
    columns[params[:order][:'0'][:column].to_i]
  end

  def sort_direction
    params[:order][:'0'][:dir] == "desc" ? "desc" : "asc"
  end
end