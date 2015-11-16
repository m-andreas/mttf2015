class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy, :pay, :remove_job, :sixt_bill, :drivers_bill, :complete_bill]
  before_action :check_transfair
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
    respond_to do |format|
      format.html
    end
  end

  def complete_bill
    respond_to do |format|
      format.html
      format.csv { send_data @bill.to_csv( col_sep: ";").encode('ISO-8859-1', 'UTF-8') }
      headers["Content-Disposition"] = "attachment; filename=\"#{@bill.print_date}_komplett.xls\""
      format.xls
    end
  end

  def sixt_bill
    respond_to do |format|
      format.html
      headers["Content-Disposition"] = "attachment; filename=\"#{@bill.print_date}_Sixt.xls\""
      format.csv { send_data @bill.to_csv( col_sep: ";").encode('ISO-8859-1', 'UTF-8') }
      format.xls { }
    end
  end

  def drivers_bill
    respond_to do |format|
      format.html
      headers["Content-Disposition"] = "attachment; filename=\"#{@bill.print_date}_Fahrer.xls\""
      format.csv { send_data @bill.to_csv( col_sep: ";").encode('ISO-8859-1', 'UTF-8') }
      format.xls { }
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
    if msg != true  && msg.length > 4
      length = msg.length
      msg = msg[0..3]
      msg << "#{ length - 4 } weitere Fehler ..."
    end
    if msg == true
      flash[:notice] = t("bills.billed")
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
    if dependencies != true && dependencies.length > 4
      length = msg.length
      dependencies = msg[0..3]
      dependencies << "#{ length - 4 } weitere Fehler ..."
    end
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
