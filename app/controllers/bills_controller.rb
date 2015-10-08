class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy, :pay, :remove_job]

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
    @bill
    respond_to do |format|
      format.html
      format.csv { send_data @bill.to_csv( col_sep: "\t") }
      format.xls { send_data @bill.to_csv(col_sep: "\t") }
    end
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
    redirect_to @bill
  end

  def destroy
    @bill.jobs.each do |job|
      job.reset_to_current_bill
    end

    @bill.destroy
    redirect_to current_bill_path
  end

  def add_jobs
    @current_bill = Bill.get_current
    msg = @current_bill.add_jobs( Job.get_open )
    if msg == true
      flash[:notice] = "Aufträge wurde verrechnet"
    else
      flash[:error] = msg
    end
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
    dependencies = @bill.pay
    if dependencies == true
      redirect_to @bill
    else
      redirect_to jobs_path, alert: dependencies
    end
  end

  private
    def set_bill
      @bill = Bill.find(params[:id])
    end

    def bill_params
      params.require(:bill).permit(:print_date)
    end
end
