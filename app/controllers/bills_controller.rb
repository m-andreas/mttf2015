class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @bills = Bill.all
    respond_with(@bills)
  end

  def old
  end

  def current
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

  private
    def set_bill
      @bill = Bill.find(params[:id])
    end

    def bill_params
      params.require(:bill).permit(:billed_at, :print_date)
    end
end
