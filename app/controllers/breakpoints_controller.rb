class BreakpointsController < ApplicationController
  before_action :set_breakpoint, only: [:show, :edit, :update, :destroy]
  before_action :check_transfair
  respond_to :html

  def index
    @breakpoints = Breakpoint.all
    respond_with(@breakpoints)
  end

  def show
    respond_with(@breakpoint)
  end

  def new
    @breakpoint = Breakpoint.new
    respond_with(@breakpoint)
  end

  def edit
  end

  def create
    @breakpoint = Breakpoint.new(breakpoint_params)
    @breakpoint.save
    respond_with(@breakpoint)
  end

  def update
    @breakpoint.update(breakpoint_params)
    respond_with(@breakpoint)
  end

  def destroy
    @breakpoint.destroy
    respond_with(@breakpoint)
  end

  private
    def set_breakpoint
      @breakpoint = Breakpoint.find(params[:id])
    end

    def breakpoint_params
      params.require(:breakpoint).permit(:position, :job_id, :distance)
    end
end
