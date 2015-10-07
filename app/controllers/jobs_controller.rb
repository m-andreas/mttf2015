class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :remove_from_current_bill,
    :add_to_current_bill, :add_co_driver, :remove_co_driver ]

  # GET /jobs
  # GET /jobs.json
  def index
  end

  def add_co_driver
    co_job = Job.find( params[ :co_job_id ].to_i )
    @job.co_jobs << co_job unless co_job.nil?
    @job.add_breakpoints
    @shuttles = @job.get_shuttle_array
    respond_to do | format |
      format.html { redirect_to jobs_path }
      format.js { render 'change_co_drivers.js.erb' }
    end
  end

  def remove_co_driver
    co_job = Job.find( params[ :co_job_id ].to_i )
    logger.info @job.co_jobs.length

    @job.remove_co_job( co_job )
    @job.add_breakpoints
    @shuttles = @job.get_shuttle_array
    respond_to do | format |
      format.html { redirect_to jobs_path }
      format.js { render 'change_co_drivers.js.erb' }
    end
  end

  def remove_from_current_bill
    @job.set_open
    redirect_to jobs_path
  end

  def add_to_current_bill
    puts "route here??"
    puts @job.inspect
    if @job.route.is_active?
      flash[:alert] = "Route ist noch nicht gesetzt. Auftrag nicht verrechnet."
    else
      @job.set_to_current_bill
      flash[:notice] = "Auftrag wurde verrechnet"
    end
    redirect_to jobs_path
  end

  def show_all
    render json: JobsAllDatatable.new(view_context)
  end

  def show_regular_jobs
    render json: JobsDatatable.new(view_context)
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
  end

  # GET /jobs/new
  def new
    @job = Job.new
    @drivers = Driver.get_active
    @addresses = Address.get_active
    @shuttles = []
  end

  # GET /jobs/1/edit
  def edit
    @drivers = Driver.get_active
    @addresses = Address.get_active
    @shuttles = @job.get_shuttle_array
    @co_jobs = @job.get_co_jobs_string
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)
    @job.status = Job::OPEN
    @job.actual_collection_date = @job.scheduled_collection_date
    @job.actual_delivery_date = @job.scheduled_delivery_date
    co_jobs = params[:co_jobs]
    driver = Driver.find_by( id: job_params[:driver_id])
    @job.driver = driver
    @job.created_by_id = current_user.id
    @job.route_id = Route.find_or_create( params[ :job ][ :from_id ] , params[ :job ][:to_id] )
    respond_to do |format|
      if @job.save && @job.add_co_jobs( co_jobs ) && @job.add_breakpoints
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @job }
      else
        @drivers = Driver.get_active
        @addresses = Address.get_active
        format.html { render :new, error: "Fehler beim speichern" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if !@job.charged? && @job.update(job_params) && @job.set_route
        if job_params["shuttle"] == "0"
          @job.remove_shuttles
        end
        if params[:subaction] == "update_and_pay"
          @job.set_to_current_bill
          format.html { redirect_to jobs_path, notice: 'Auftrag wurde aktualisiert und der aktuellen Verrechnung hinzugefügt' }
        else
          format.html { redirect_to jobs_path, notice: 'Auftrag wurde erfolgreicht aktualisiert.' }
        end
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    unless @job.charged?
      @job.status = Job::DELETED
      @job.save!
      respond_to do |format|
        format.html { redirect_to jobs_url, notice: 'Auftrag gelöscht' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @job, notice: 'Verrechnete Aufträge können nicht gelöscht werden' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit( { :breakpoints_attributes => [ :address_id, :id, :position, :distance ]}, :driver_id, :co_jobs, :cost_center_id, :route_id, :from_id, :to_id, :shuttle, :co_driver_ids, :car_brand, :car_type, :registration_number,
        :scheduled_collection_date, :scheduled_delivery_date, :actual_collection_date, :actual_delivery_date, :chassis_number, :mileage_delivery, :mileage_collection, :job_notice, :transport_notice, :transport_notice_extern )
    end
end
