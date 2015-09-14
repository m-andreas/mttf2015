class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.page params[:page]
  end

  def datatable_ajax 
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
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)
    logger.info params.inspect
    co_jobs = params[:co_jobs]
    driver = Driver.find(params[:driver_id])
    @job.driver = driver
    @job.created_by_id = current_user.id
    @job.route_id = Route.find_or_create( params[ :job ][ :from_id ] , params[ :job ][:to_id] )
    respond_to do |format|
      if @job.save && @job.add_co_jobs( co_jobs )
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
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:driver_id, :cost_center_id, :route_id, :from_id, :to_id, :shuttle, :co_driver_ids)
    end
end
