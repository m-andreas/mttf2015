class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :remove_from_current_bill,
    :add_to_current_bill, :add_co_job, :remove_co_job, :print_job, :set_to_print ]
  before_action :check_transfair, except: [ :multible_cars, :create_sixt, :new_sixt, :index  ]
  # GET /jobs
  # GET /jobs.json
  def index
    redirect_to job_new_sixt_path unless current_user.is_intern?
  end

  def add_co_driver # just add graphical, real add at update or create
    @drivers = Driver.get_active
    @number_of_co_drivers = params[:number_of_co_drivers].to_i + 1
    respond_to do | format | format.html { redirect_to jobs_path }
      format.js { render 'add_co_driver.js.erb' }
    end
  end

  def add_co_job
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
    respond_to do | format |
      format.html { redirect_to jobs_path }
      format.js { render 'change_co_jobs.js.erb' }
    end
  end

  def remove_co_job
    if @job.is_open?
      co_job = Job.find( params[ :co_job_id ].to_i )
      logger.info @job.co_jobs.length

      @job.remove_co_job( co_job )
      @job.add_breakpoints
    end
    @shuttles = @job.get_shuttle_array
    respond_to do | format |
      format.html { redirect_to jobs_path }
      format.js { render 'change_co_jobs.js.erb' }
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
      flash[:notice] = t("jobs.billed")
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

  def print_job
    @job
    respond_to do |format|
      format.html
      headers["Content-Disposition"] = "attachment; filename=\"Auftrag_#{@job.id}.xls\""
      format.xls
    end
  end

  # GET /jobs/new
  def new( job_amount = 1 )
    @job_amount = job_amount
    @job_values = []
    @job = Job.new
    @drivers = Driver.get_active
    @addresses = Address.get_active.order(:address_short)
    @shuttles = []
    @co_driver_ids = []
    @co_job_ids = ""
  end

  # GET /jobs/1/edit
  def edit
    @co_driver_ids = @job.get_co_driver_ids
    @number_of_co_drivers = @co_driver_ids.length
    @drivers = Driver.get_active
    @addresses = Address.get_active
    @shuttles = @job.get_shuttle_array
    @co_jobs = @job.get_co_jobs_string
  end

  # POST /jobs
  # POST /jobs.json
  def create
    unless job_params[:scheduled_collection_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[0-9]{4}( [0-2][0-9]:[0-6][0-9])?\z/  &&
      job_params[:scheduled_delivery_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[0-9]{4}( [0-2][0-9]:[0-6][0-9])?\z/
      error = t("jobs.date_format")
      job_errors = error
      params[:job].except! :scheduled_delivery_time
      params[:job].except! :scheduled_collection_time
    else
      @job = Job.new(job_params)
      @job.status = Job::OPEN
      @job.shuttle = false if @job.shuttle.nil?
      @job.actual_collection_time = @job.scheduled_collection_time
      @job.actual_delivery_time = @job.scheduled_delivery_time
      driver = Driver.find_by( id: job_params[:driver_id])
      @job.driver = driver
      @job.created_by_id = current_user.id
      @job.route_id = Route.find_or_create( params[ :job ][ :from_id ] , params[ :job ][:to_id] )
      co_jobs = params[:co_jobs]
      job_errors = @job.check_co_job_ids( co_jobs )
      if @job.scheduled_collection_time > @job.scheduled_delivery_time
        error = t("jobs.date_error")
        if job_errors == true
          job_errors = [ error ]
        else
          job_errors << error
        end
      end
      if params[:co_driver_ids].present? && params[:co_driver_ids].length > 0 && @job.shuttle?
        if job_errors == true
          job_errors = [ "Auftrag kann nicht mehrere Fahrer haben und ein Shuttle sein." ]
        else
          job_errors << "Auftrag kann nicht mehrere Fahrer haben und ein Shuttle sein."
        end
      end
    end


    respond_to do |format|

      if job_errors == true && @job.save && @job.add_co_jobs( co_jobs ) && @job.add_breakpoints && @job.add_co_drivers(params[:co_driver_ids])
        AuftragsMailer.job_confirmation(@job,current_user).deliver
        format.html { redirect_to jobs_path, notice: t("jobs.created") }
      else
        @co_job_ids = params[:co_jobs]
        @co_driver_ids = params[:co_driver_ids] || []
        @job = Job.new(job_params)
        @drivers = Driver.get_active
        @addresses = Address.get_active
        @shuttles = []
        co_jobs = @job.co_job_ids_to_co_jobs(params[:co_jobs])
        co_jobs.each do |co_job|
          fullname = co_job.driver.nil? ? "" : co_job.driver.fullname_id
          @shuttles << [ fullname, co_job.id ]
        end
        flash[:error] = job_errors
        format.html { render :action => 'new' }
      end
    end
  end

  def new_sixt()
    @job_amount = 1
    @addresses = Address.get_active.order(:address_short)
  end

  def create_sixt
    i = 0
    jobs = []
    jobs_params[:jobs].each do |single_params|
      next if single_params[:registration_number].empty?
      from = Address.find_by(id: single_params[:from_id])
      to = Address.find_by(id: single_params[:to_id])
      if from.nil? || to.nil?
        redirect_to :back, notice: t("jobs.save_error")
        return
      end
      unless single_params[:opening_hours].empty?
        from.opening_hours = single_params[:opening_hours]
        from.save
      end
      single_params.except! :opening_hours
      job = Job.new(single_params)
      job.status = Job::OPEN
      job.shuttle = false
      job.scheduled_collection_time = Time.now.strftime("%d.%m.%Y")
      job.scheduled_delivery_time = Time.now.strftime("%d.%m.%Y")
      job.route_id = Route.find_or_create( from.id , to.id )
      job.to_print = true
      ret = job.save
      unless ret == true
        redirect_to :back, notice: t("jobs.save_error")
      end
      jobs << job
      i += 1
    end
    if i > 1
      AuftragsMailer.mass_job_confirmation(jobs,current_user).deliver
    elsif i == 1
      AuftragsMailer.job_confirmation(jobs.first,current_user).deliver
    end
    redirect_to job_new_sixt_path, notice: i.to_s + " " + t("jobs.created_multible")
  end

  def multible_cars
    @addresses = Address.get_active
    @job_amount = params[:job_amount].to_i
    render :action => 'new_sixt'
  end

  def set_to_print
    @job.to_print = true
    @job.save
    redirect_to jobs_path, notice: t('jobs.sent_to_printer')
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if params[:co_driver_ids].present? && params[:co_driver_ids].length > 0 && job_params[:shuttle] == "1"
        flash[:error] = "Auftrag kann nicht mehrere Fahrer haben und ein Shuttle sein."
        @addresses = Address.get_active
        @shuttles = @job.get_shuttle_array
        @co_jobs = @job.get_co_jobs_string
        format.html { redirect_to :back }
      end
      if @job.is_open? && @job.update(job_params) && @job.set_route && @job.add_co_drivers(params[:co_driver_ids])
        if job_params["shuttle"] == "0"
          @job.remove_shuttles
        end
        if params[:subaction] == "update_and_pay"
          msg = @job.check_for_billing
          if msg == true
            @job.set_to_current_bill
            flash[:notice] = t("jobs.updated_and_billed")
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
          format.html { redirect_to jobs_path, notice: t('jobs.updated') }
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
      @job.delete

      flash[:notice] = 'Auftrag wurde entfernt'
      respond_to do |format|
        format.html { redirect_to jobs_url, notice: t("jobs.deleted") }
        format.js   { render :layout => false }
        format.json { head :no_content }
      end
    else
      flash[:notice] = 'Auftrag konnte nicht entfernt werden'
      respond_to do |format|
        format.html { redirect_to @job, notice: t("jobs.cant_delete_billed") }
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
    params.require(:job).permit( { :breakpoints_attributes => [ :address_id, :id, :position, :mileage ]}, :driver_id, :co_jobs, :cost_center_id, :route_id, :from_id, :to_id, :shuttle, :car_brand, :car_type, :registration_number,
      :scheduled_collection_time, :scheduled_delivery_time, :actual_collection_time, :actual_delivery_time, :chassis_number, :mileage_delivery, :mileage_collection, :job_notice, :transport_notice, :transport_notice_extern )
  end

  def jobs_params
    params.permit( :jobs => [ :registration_number, :cost_center_id, :car_brand, :car_type, :from_id, :to_id, :job_notice, :opening_hours ]  )
  end
end
