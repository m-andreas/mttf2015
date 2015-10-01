class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy, :pay]

  respond_to :html

  def index
    @bills = Bill.all
    respond_with(@bills)
  end

  def old
    @bills = Bill.get_old
    respond_with(@bills)
  end

  def current
    @bill = Bill.get_current_with_includes
  end

  def show
    respond_with(@bill)
  end

  def new
    @bill = Bill.new
    respond_with(@bill)
  end

  def edit
  end

  def create
    @bill = Bill.new(bill_params)
    @bill.save
    respond_with(@bill)
  end

  def update
    @bill.update(bill_params)
    respond_with(@bill)
  end

  def destroy
    @bill.destroy
    respond_with(@bill)
  end

  def add_jobs_to_bill
    @current_bill = Bill.get_current
    @current_bill.add_jobs( Job.get_open )
    redirect_to current_bill_path
  end

  def delete_current
    @current_bill = Bill.get_current
    @current_bill.jobs.each do |job|
      job.set_open
    end
    @current_bill.destroy
    redirect_to jobs_path
  end

  def pay
    @bill.pay
    redirect_to @bill
  end

  private
    def set_bill
      @bill = Bill.find(params[:id])
    end

    def bill_params
      params.require(:bill).permit(:billed_at, :print_date)
    end
end
