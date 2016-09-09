class ShuttleCarsController < ApplicationController
  before_action :check_transfair, except: [ ]
  before_action :set_shuttle_car, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @shuttle_cars = ShuttleCar.all
    respond_with(@shuttle_cars)
  end

  def show
    respond_with(@shuttle_car)
  end

  def new
    @shuttle_car = ShuttleCar.new
    respond_with(@shuttle_car)
  end

  def edit
  end

  def create
    @shuttle_car = ShuttleCar.new(shuttle_car_params)
    @shuttle_car.save
    respond_with(@shuttle_car)
  end

  def update
    @shuttle_car.update(shuttle_car_params)
    respond_with(@shuttle_car)
  end

  def destroy
    @shuttle_car.destroy
    respond_with(@shuttle_car)
  end

  private
    def set_shuttle_car
      @shuttle_car = ShuttleCar.find(params[:id])
    end

    def shuttle_car_params
      params.require(:shuttle_car).permit(:car_brand, :car_type, :registration_number)
    end
end
