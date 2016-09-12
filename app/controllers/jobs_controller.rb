class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :remove_from_current_bill,
    :add_to_current_bill, :print_job, :set_to_print, :add_shuttle_breakpoint, :remove_shuttle_breakpoint, :change_breakpoint_distance, :add_shuttle_passenger, :remove_shuttle_passenger,
    :change_breakpoint_address, :change_to_shuttle, :set_shuttle_route_and_pay, :unset_shuttle ]
  before_action :check_transfair, except: [ :multible_cars, :create_sixt, :new_sixt, :index  ]
  # GET /jobs
  # GET /jobs.json
  def index
    redirect_to job_new_sixt_path unless current_user.is_intern?
  end

  def add_co_driver # just add graphical, real add at update or create
    @drivers = Driver.get_active
    @number_of_co_drivers = params[:number_of_co_drivers].to_i + 1
    respond_to do | format |
      format.html { redirect_to jobs_path }
      format.js { render 'add_co_driver.js.erb' }
    end
  end

  def add_shuttle_breakpoint
    count = params[:count].to_i
    @job.add_shuttle_breakpoint count
    respond_to do | format |
      @shuttle_data = @job.get_shuttle_data
      @drivers = Driver.get_active
      @addresses = Address.get_active
      format.js { render 'rerender_shuttle.js.erb' }
    end
  end

  def remove_shuttle_breakpoint
    count = params[:count].to_i - 1
    @job.remove_shuttle_breakpoint(count)
    respond_to do | format |
      @shuttle_data = @job.get_shuttle_data
      @drivers = Driver.get_active
      @addresses = Address.get_active
      format.js { render 'rerender_shuttle.js.erb' }
    end
  end

  def add_shuttle_passenger
    count = params[:count].to_i
    passenger = Driver.find_by_id(params[:driver_id].to_i)
    @job.add_shuttle_passenger passenger, count
    @job.set_passengers
    @shuttle_data = @job.get_shuttle_data
    respond_to do | format |
      format.js { render '_shuttle_passengers.html.erb', :locals => {  :i => count } }
    end
  end

  def remove_shuttle_passenger
    count = params[:count].to_i
    passenger = Driver.find_by_id(params[:driver_id])
    @job.remove_shuttle_passenger passenger, count
    @job.set_passengers
    @shuttle_data = @job.get_shuttle_data
    respond_to do | format |
      format.js { render 'remove_shuttle_passenger.js.erb', :locals => {  :i => count } }
    end
  end

  def change_breakpoint_distance
    if params[:count] == "START" || params[:count] == "END"
      count = params[:count]
    else
      count = params[:count].to_i
    end
    distance = params[:distance].to_i
    @job.change_breakpoint_distance( distance, count )
    respond_to do | format |
      format.json { render 'change_breakpoint_distance.js.erb' }
    end
  end

  def change_breakpoint_address
    @count = params[:count].to_i
    @address = Address.find_by_id(params[:address_id].to_i)
    unless @address.nil?
      @job.change_breakpoint_address( @address, @count )
    end
    respond_to do | format |
      format.json { render 'change_breakpoint_address.js.erb' }
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
  end

  def new_shuttle
    @job = Job.new
    @shuttle_cars = ShuttleCar.all
  end

  # GET /jobs/1/edit
  def edit
    @co_driver_ids = @job.get_co_driver_ids
    @number_of_co_drivers = @co_driver_ids.length
    @drivers = Driver.get_active
    @addresses = Address.get_active
    if @job.shuttle?
      @shuttle_data = @job.get_shuttle_data
    end
  end

  def change_to_shuttle
    @job.set_shuttle
    @co_driver_ids = @job.get_co_driver_ids
    @number_of_co_drivers = @co_driver_ids.length
    @drivers = Driver.get_active
    @addresses = Address.get_active
    @shuttle_data = @job.get_shuttle_data
    render "edit"
  end

  def unset_shuttle
    @job.unset_shuttle
    @co_driver_ids = @job.get_co_driver_ids
    @number_of_co_drivers = @co_driver_ids.length
    @drivers = Driver.get_active
    @addresses = Address.get_active
    render "edit"
  end

  def create_shuttle
    logger.info params.inspect
    @job = Job.new
    @job.status = Job::OPEN
    @job.created_by_id = current_user.id
    @job.to_print = false
    if params.has_key?(:shuttle_car)
      shuttle_car = ShuttleCar.where( id: params[:shuttle_car] ).first
      unless shuttle_car.nil?
        @job.apply_shuttle_car_data( shuttle_car )
      end
    end

    if !params[:job].nil? && job_params[:scheduled_collection_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[1-9][0-9]{3}( [0-2][0-9]:[0-6][0-9])?\z/
      @job.scheduled_collection_time = job_params[:scheduled_collection_time]
      @job.actual_collection_time = @job.scheduled_collection_time
      logger.info job_params[:scheduled_collection_time]
    end
    if !params[:job].nil? && job_params[:scheduled_delivery_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[1-9][0-9]{3}( [0-2][0-9]:[0-6][0-9])?\z/
      @job.scheduled_delivery_time = job_params[:scheduled_delivery_time]
      @job.actual_delivery_time = @job.scheduled_delivery_time
    end
    @job.save
    @job.set_shuttle
    @co_driver_ids = @job.get_co_driver_ids
    @number_of_co_drivers = @co_driver_ids.length
    @drivers = Driver.get_active
    @addresses = Address.get_active
    if @job.shuttle?
      @shuttle_data = @job.get_shuttle_data
    end
    respond_to do |format|
      if @job.save
        format.html { redirect_to edit_job_path(@job), notice: t("jobs.created") }
      else
        format.html { redirect_to :back }
      end
    end
  end

  # POST /jobs
  # POST /jobs.json
  def create
    job_errors = true
    unless job_params[:scheduled_collection_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[1-9][0-9]{3}( [0-2][0-9]:[0-6][0-9])?\z/  &&
      job_params[:scheduled_delivery_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[1-9][0-9]{3}( [0-2][0-9]:[0-6][0-9])?\z/
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

    if params[:co_driver_ids].present? && params[:co_driver_ids].length > 0
      params[:co_driver_ids].each do |co_driver_id|
        Passenger.create(driver_id: co_driver_id, job: @job)
      end
    end

    respond_to do |format|
      if job_errors == true && @job.save
        AuftragsMailer.job_confirmation(@job,current_user).deliver
        format.html { redirect_to jobs_path, notice: t("jobs.created") }
      else
        @co_driver_ids = params[:co_driver_ids] || []
        @job = Job.new(job_params)
        @drivers = Driver.get_active
        @addresses = Address.get_active

        flash[:error] = job_errors
        format.html { render :action => 'new' }
      end
    end
  end

  def new_sixt()
    @job_amount = 1
    @addresses = Address.get_active.order(:address_short)
    @jobs = [{}]
  end

  def create_sixt
    i = 0
    jobs = []
    if params[:commit] == "erstellen"
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
    elsif params[:commit] == "anlegen"
      a = Address.create(address_params)
      @addresses = Address.get_active
      @job_amount = params[:job_amount].to_i
      @jobs = jobs_params[:jobs]
      render :action => 'new_sixt'
    else
      @job_amount = params[:job_amount].to_i
      @jobs = jobs_params[:jobs]
      render :action => 'new_sixt'
    end
  end

  def multible_cars
    @addresses = Address.get_active
    @job_amount = params[:job_amount].to_i
    @jobs = []
    @job_amount.times do |i|
      @jobs << {}
    end
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
      if !( job_params[:scheduled_collection_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[2-9][0-9]{3}( [0-2][0-9]:[0-6][0-9])?\z/ || job_params[:scheduled_collection_time].nil? || job_params[:scheduled_collection_time].empty? ) ||
        !( job_params[:scheduled_delivery_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[2-9][0-9]{3}( [0-2][0-9]:[0-6][0-9])?\z/ || job_params[:scheduled_delivery_time].nil? || job_params[:scheduled_delivery_time].empty? ) ||
        !( job_params[:actual_collection_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[2-9][0-9]{3}( [0-2][0-9]:[0-6][0-9])?\z/ || job_params[:actual_collection_time].nil? || job_params[:actual_collection_time].empty? ) ||
        !( job_params[:actual_delivery_time] =~ /\A[0-9][0-9]?\.[0-9][0-9]?\.[2-9][0-9]{3}( [0-2][0-9]:[0-6][0-9])?\z/ || job_params[:actual_delivery_time].nil? || job_params[:actual_delivery_time].empty? )
        flash[:error] = t("jobs.date_format")
        @drivers = Driver.get_active
        @addresses = Address.get_active
        return redirect_to :back
      end
      if params[:co_driver_ids].present? && params[:co_driver_ids].length > 0 && @job.shuttle?
        flash[:error] = "Auftrag kann nicht mehrere Fahrer haben und ein Shuttle sein."
            @drivers = Driver.get_active
            @addresses = Address.get_active
            return redirect_to :back
      end
      if @job.is_open? && @job.update(job_params) && @job.add_co_drivers(params[:co_driver_ids]) && @job.set_route
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
            format.html { redirect_to :back }
          end
        else
          if params[:subaction] == "update_and_edit"
            format.html { redirect_to edit_job_path(@job), notice: t('jobs.updated') }
          else
            format.html { redirect_to jobs_path, notice: t('jobs.updated') }
          end
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
    params.require(:job).permit( :driver_id, :cost_center_id, :route_id, :from_id, :to_id, :shuttle, :car_brand, :car_type, :registration_number,
      :scheduled_collection_time, :scheduled_delivery_time, :actual_collection_time, :actual_delivery_time, :chassis_number, :mileage_delivery, :mileage_collection,
      :job_notice, :transport_notice, :transport_notice_extern )
  end

  def address_params
    params.permit( :country, :city, :zip_code, :address, :address_short, :opening_hours )
  end

  def jobs_params
    params.permit( :jobs => [ :registration_number, :cost_center_id, :car_brand, :car_type, :from_id, :to_id, :job_notice, :opening_hours ]  )
  end
end
