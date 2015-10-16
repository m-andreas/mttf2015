class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]
  before_action :check_transfair
  # GET /routes
  # GET /routes.json
  def index
    @routes = Route.get_active
  end

  # GET /routes/1
  # GET /routes/1.json
  def show
  end

  def show_new
    @routes = Route.get_new
  end

  # GET /routes/new
  def new
    @route = Route.new
    @addresses = Address.get_active
    @calculation_bases = Route.get_calculation_bases
  end

  # GET /routes/1/edit
  def edit
    @addresses = Address.get_active
    @calculation_bases = Route.get_calculation_bases
  end

  # POST /routes
  # POST /routes.json
  def create
    @route = Route.new(route_params)

    respond_to do |format|
      if @route.save
        format.html { redirect_to @route, notice: 'Die Route wurde erfolgreich erstellt' }
        format.json { render :show, status: :created, location: @route }
      else
        format.html { render :new }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /routes/1
  # PATCH/PUT /routes/1.json
  def update
    @route.set_processed
    respond_to do |format|
      if @route.update(route_params)
        format.html { redirect_to new_routes_path, notice: 'Die Route wurde aktualisiert und aktiv gesetzt' }
        format.json { render :show, status: :ok, location: @route }
      else
        format.html { render :edit }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /routes/1
  # DELETE /routes/1.json
  def destroy
    @route.delete
    respond_to do |format|
      format.html { redirect_to routes_url, notice: 'Die Route wurde gelöscht' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @route = Route.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def route_params
      params.require(:route).permit(:from_id, :to_id, :calculation_basis, :distance, :status)
    end
end
