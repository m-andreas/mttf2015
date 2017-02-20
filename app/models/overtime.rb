class Overtime
  CORE_START_TIME_WEEKDAY = "08:00"
  CORE_END_TIME_WEEKDAY = "17:00"
  CORE_START_TIME_SATURDAY = "08:00"
  CORE_END_TIME_SATURDAY = "13:00"
  OVERTIME_DOUBLE_START = "22:00"
  OVERTIME_DOUBLE_END = "05:00"
  def self.get_times_per_month date
    jobs = Job.eager_load(:passengers, :driver, :from, :to, :passengers_drivers).where("actual_collection_time >= :time_start and " +
      "actual_collection_time <= :time_end and status in (:status)",
      time_start: date.beginning_of_month, time_end: date.end_of_month, status: [ Job::FINISHED, Job::CHARGED ] )
    if jobs.nil?
      return []
    end
    @overtimes = []
    drivers = []
    jobs.each do |job|
      drivers << job.driver unless job.driver.nil?
      job.passengers_drivers.each do |passenger|
        drivers << passenger
      end
    end

    drivers.uniq!
    drivers = drivers.sort_by{|e| e[:id]}
    drivers.each do |driver|
      drivers_jobs = []
      overtime_line = {name: driver.fullname_id}
      overtime_line[:id] = driver.id
      #drivers_jobs = jobs.where( "jobs.driver_id = :driver_id or passengers.driver_id = :driver_id", driver_id: driver.id )
      puts driver.inspect
      overtime_line[:time] = get_overtime( driver, jobs )["total"]
      #abroad_line[:jobs] = drivers_jobs
      @overtimes << overtime_line
    end
    return @overtimes
  end

  def self.driver_total_overtime( driver, date )
    jobs = Job.eager_load(:passengers, :driver, :from, :to).where("actual_collection_time >= :time_start and " +
      "actual_collection_time < :time_end and ( jobs.driver_id = :driver_id or passengers.driver_id = :driver_id ) and status in (:status)",
      time_start: date.beginning_of_month, time_end: date.beginning_of_month + 1.month, driver_id: driver.id, status: [ Job::FINISHED, Job::CHARGED ] )

    return get_overtime( driver, jobs )
  end

  def self.calc start_time, end_time
    unless ( start_time.nil? || end_time.nil? ) || ( start_time.is_a?( String ) && start_time.blank?) || ( end_time.is_a?( String ) && end_time.blank?)
      end_time = end_time.to_time
      start_time = start_time.to_time
      if start_time > end_time
        return ( ( end_time.to_time + 1.day ) - start_time.to_time ) / 3600
      else
        return ( end_time.to_time - start_time.to_time ) / 3600
      end
    else
      return 0
    end
  end

  private
    def self.get_overtime driver, jobs
      overtime = {}
      overtime_count = 0
      all_dates =
      calculations = {}
      jobs.group_by(&:group_date).each do |date, job_group|
        job_day = DateTime.strptime( date + " 12:00", "%Y-%m-%d %H:%M")
        daily_overtime, calculation = self.daily_overtime( job_day, job_group, driver )
        overtime_count += daily_overtime
        calculations[ date ] = calculation
      end
      overtime["total"] = overtime_count
      overtime["calculations"] = calculations
      overtime["jobs"] = jobs
      return overtime
    end

    def self.daily_overtime job_day, job_group, driver
      overtime = 0
      calculation = []
      date = job_day.strftime( "%Y-%m-%d" )
      jobs_with_driver = job_group.select{ |job| job.driver == driver || job.passengers.map(&:driver_id).include?( driver.id ) }
      return 0, "" if jobs_with_driver.empty?
      jobs_with_driver = jobs_with_driver.sort_by {|j| j.actual_collection_time }
      jobs_with_driver.each_with_index do |single_job, i|
        calculation << "Fahrt #{i + 1}: #{single_job.from.show_address} - #{single_job.to.show_address} ( #{single_job.actual_collection_time.strftime('%H:%M')} - #{single_job.actual_delivery_time.strftime('%H:%M')})"
      end
      if job_day.sunday?
        # Am Morgen
          time_diff = TimeDifference.between( jobs_with_driver.first.actual_collection_time, jobs_with_driver.last.actual_delivery_time).in_hours
          overtime += time_diff * 2
          calculation << "#{time_diff} x 2 ( Sonntagszuschlag ) = #{overtime}"
      else
        if job_day.saturday?
          start_time_core = DateTime.strptime( date + " " + CORE_START_TIME_SATURDAY, "%Y-%m-%d %H:%M" )
          end_time_core = DateTime.strptime( date + " " + CORE_END_TIME_SATURDAY, "%Y-%m-%d %H:%M" )
        else
          start_time_core = DateTime.strptime( date + " " + CORE_START_TIME_WEEKDAY, "%Y-%m-%d %H:%M" )
          end_time_core = DateTime.strptime( date + " " + CORE_END_TIME_WEEKDAY, "%Y-%m-%d %H:%M" )
        end
        start_time_double = DateTime.strptime( date + " " + OVERTIME_DOUBLE_START, "%Y-%m-%d %H:%M" )
        end_time_double = DateTime.strptime( date + " " + ( OVERTIME_DOUBLE_END ), "%Y-%m-%d %H:%M" ) + 1.day

        # Am Morgen
        if jobs_with_driver.first.actual_collection_time < start_time_core
          if jobs_with_driver.first.actual_collection_time < ( end_time_double - 1.day )
            time_diff = TimeDifference.between( start_time_core, ( end_time_double - 1.day )).in_hours
            overtime += time_diff
            calculation << "#{time_diff} ( vor #{job_day.saturday? ? CORE_START_TIME_SATURDAY : CORE_START_TIME_WEEKDAY}" +
            "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
            time_diff = TimeDifference.between( (end_time_double - 1.day), jobs_with_driver.first.actual_collection_time).in_hours
            overtime += time_diff * 2
            calculation << "#{time_diff} x 2 ( vor #{OVERTIME_DOUBLE_END}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff * 2}"
          else
            time_diff = TimeDifference.between( start_time_core, jobs_with_driver.first.actual_collection_time).in_hours
            overtime += time_diff
            calculation << "#{time_diff} ( vor #{job_day.saturday? ? CORE_START_TIME_SATURDAY : CORE_START_TIME_WEEKDAY}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff}"
          end
        elsif jobs_with_driver.first.actual_collection_time > start_time_core
          time_diff = TimeDifference.between( start_time_core, jobs_with_driver.first.actual_collection_time).in_hours
          overtime -= time_diff
          calculation << "-#{time_diff} ( nach #{job_day.saturday? ? CORE_START_TIME_SATURDAY : CORE_START_TIME_WEEKDAY}" +
            "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
        end

        #Am Abend
        if jobs_with_driver.last.actual_delivery_time > end_time_core
          if jobs_with_driver.last.actual_delivery_time > start_time_double
            if jobs_with_driver.last.actual_delivery_time > end_time_double
              time_diff = TimeDifference.between( start_time_double, end_time_core ).in_hours
              overtime += time_diff * 1.5
              calculation << "#{time_diff} x 1,5 ( nach #{job_day.saturday? ? CORE_END_TIME_SATURDAY : CORE_END_TIME_WEEKDAY}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff * 1.5}"
              time_diff = TimeDifference.between( start_time_double, end_time_double).in_hours
              overtime += time_diff * 2
              calculation << "#{time_diff} x 2 ( nach #{OVERTIME_DOUBLE_START}" +
                "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff * 2}"
              time_diff = TimeDifference.between( end_time_double, jobs_with_driver.last.actual_delivery_time ).in_hours
              overtime += time_diff
              calculation << "#{time_diff} ( nach #{OVERTIME_DOUBLE_END}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} am Tag darauf ) = #{time_diff}"
            else
              time_diff = TimeDifference.between( start_time_double, end_time_core ).in_hours
              overtime += time_diff * 1.5
              calculation << "#{time_diff} x 1,5 ( nach #{job_day.saturday? ? CORE_END_TIME_SATURDAY : CORE_END_TIME_WEEKDAY}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff * 1.5}"
              time_diff = TimeDifference.between( start_time_double, jobs_with_driver.last.actual_delivery_time).in_hours
              overtime += time_diff * 2
              calculation << "#{time_diff} x 2 ( nach #{OVERTIME_DOUBLE_START}" +
                "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff * 2}"
            end
          else
            time_diff =  TimeDifference.between( end_time_core, jobs_with_driver.last.actual_delivery_time).in_hours
            overtime += time_diff * 1.5
            calculation << "#{time_diff} x 1.5 ( nach #{job_day.saturday? ? CORE_END_TIME_SATURDAY : CORE_END_TIME_WEEKDAY}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff * 1.5}"
          end
        elsif jobs_with_driver.last.actual_delivery_time < end_time_core
          time_diff =  TimeDifference.between( end_time_core, jobs_with_driver.last.actual_delivery_time).in_hours
          overtime -= time_diff
          calculation << "-#{time_diff} ( vor #{job_day.saturday? ? CORE_END_TIME_SATURDAY : CORE_END_TIME_WEEKDAY}" +
            "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
        end
      end
      calculation << "Gesamt = #{overtime}"
      return overtime, calculation
    end
end