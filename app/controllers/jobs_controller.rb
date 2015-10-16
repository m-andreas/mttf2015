class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :remove_from_current_bill,
    :add_to_current_bill, :add_co_driver, :remove_co_driver ]
  before_action :check_transfair, except: [ :new, :create, :show_all, :index ]

  # GET /jobs
  # GET /jobs.json
  def index
    redirect_to new_job_path unless current_user.is_intern?
  end

  def add_co_driver
    if @job.is_open?
      @job.shuttle = true
      @job.save
      co_job = Job.find( params[ :co_job_id ].to_i )
      co_job_error = @job.check_co_jobs( [co_job] )
      if co_job_error == true
        @job.co_jobs << co_job unless co_job.nil?
        @job.add_breakpoints
      else
        flash[:error] = co_job_error
      end
    end
    @shuttles = @job.get_shuttle_array
    respond_to do | format | format.html { redirect_to jobs_path }
      format.js { render 'change_co_drivers.js.erb' }
    end
  end

  def remove_co_driver
    if @job.is_open?
      co_job = Job.find( params[ :co_job_id ].to_i )
      logger.info @job.co_jobs.length

      @job.remove_co_job( co_job )
      @job.add_breakpoints
    end
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
    msg = @job.check_for_billing
    if msg == true
      @job.set_to_current_bill
      flash[:notice] = "Auftrag wurde verrechnet"
    else
      flash[:error] = msg
    end
    respond_to do |format|
        format.html { redirect_to jobs_path }
        format.js   { render :layout => false }
        format.json { head :no_content }
    end
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

    @job.actual_collection_time = @job.scheduled_collection_time
    @job.actual_delivery_time = @job.scheduled_delivery_time
    co_jobs = params[:co_jobs]
    driver = Driver.find_by( id: job_params[:driver_id])
    @job.driver = driver
    @job.created_by_id = current_user.id
    @job.route_id = Route.find_or_create( params[ :job ][ :from_id ] , params[ :job ][:to_id] )
    job_errors = @job.check_co_job_ids( co_jobs )
    if @job.scheduled_collection_time > @job.scheduled_delivery_time
      error = "Abfahrtsdatum liegt nach Ankunftsdatum"
      if job_errors == true
        job_errors = error
      else
        job_errors += error
      end
    end
    respond_to do |format|
      if job_errors == true && @job.save && @job.add_co_jobs( co_jobs ) && @job.add_breakpoints
        format.html { redirect_to jobs_path, notice: 'Job was successfully created.' }
      else
        @drivers = Driver.get_active
        @addresses = Address.get_active
        flash[:error] = job_errors
        format.html { redirect_to new_job_path }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.is_open? && @job.update(job_params) && @job.set_route
        if job_params["shuttle"] == "0"
          @job.remove_shuttles
        end
        if params[:subaction] == "update_and_pay"
          msg = @job.check_for_billing
          if msg == true
            @job.set_to_current_bill
            flash[:notice] = 'Auftrag wurde aktualisiert und der aktuellen Verrechnung hinzugefügt'
            format.html { redirect_to jobs_path }
          else
            flash[:error] = msg
            @drivers = Driver.get_active
            @addresses = Address.get_active
            @shuttles = @job.get_shuttle_array
            @co_jobs = @job.get_co_jobs_string
            format.html { redirect_to :back }
          end
        else
          format.html { redirect_to jobs_path, notice: 'Auftrag wurde erfolgreicht aktualisiert.' }
        end
      else
        flash[:error] = "Editieren fehlgeschlagen"
        format.html { redirect_to jobs_path }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    unless @job.charged?
      @job.status = Job::DELETED
      @job.save!
      @job.remove_shuttles
      @job.remove_in_shuttles
      flash[:notice] = 'Auftrag wurde entfernt'
      respond_to do |format|
        format.html { redirect_to jobs_url, notice: 'Auftrag gelöscht' }
        format.js   { render :layout => false }
        format.json { head :no_content }
      end
    else
      flash[:notice] = 'Auftrag konnte nicht entfernt werden'
      respond_to do |format|
        format.html { redirect_to @job, notice: 'Verrechnete Aufträge können nicht gelöscht werden' }
        format.js   { render :layout => false }
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
      params.require(:job).permit( { :breakpoints_attributes => [ :address_id, :id, :position, :mileage ]}, :driver_id, :co_jobs, :cost_center_id, :route_id, :from_id, :to_id, :shuttle, :co_driver_ids, :car_brand, :car_type, :registration_number,
        :scheduled_collection_time, :scheduled_delivery_time, :actual_collection_time, :actual_delivery_time, :chassis_number, :mileage_delivery, :mileage_collection, :job_notice, :transport_notice, :transport_notice_extern )
    end
end
