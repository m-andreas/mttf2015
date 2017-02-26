class OvertimesController < ApplicationController
  before_action :check_transfair
  # GET /addresses
  # GET /addresses.json
  def index
    d1 = Date.parse('sep 1 2016')
    d2 = Date.today

    @months = (d1..d2).map{ |m| I18n.l(m, format: :month_with_year) }.uniq.reverse
  end

  # GET /addresses/1
  # GET /addresses/1.json
  def show
    month, year = params[:month_string].split("_")
    month_number = I18n.t( :month_names, :scope => :date ).index(month.capitalize)
    @date = Date.strptime("#{month_number}.#{year}", "%m.%Y")
    @date_string = "#{month.capitalize} #{year.to_s}"
    @overtimes = Overtime.get_times_per_month( @date )
  end

  def show_driver
    @driver = Driver.find(params[:driver_id])
    @date = params[:date].to_date
    overtime = Overtime.driver_total_overtime @driver, @date
    @missing_days = overtime["missing_days"]
    @total= overtime["total"]
    @jobs = overtime["jobs"]
    @calculations = overtime["calculations"]
  end
end
