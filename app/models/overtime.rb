class Overtime
  CORE_START_TIME_WEEKDAY = "08:00"
  CORE_END_TIME_WEEKDAY = "17:00"
  CORE_START_TIME_SATURDAY = "08:00"
  CORE_END_TIME_SATURDAY = "13:00"
  OVERTIME_DOUBLE_START = "22:00"
  OVERTIME_DOUBLE_END = "05:00"

  def self.get_drivers_per_month date
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
    return [ drivers.sort_by{|e| e[:id]}, jobs ]
  end

  def self.get_times_per_month date
    drivers, jobs = get_drivers_per_month date

    drivers.each do |driver|
      drivers_jobs = []
      overtime_line = {name: driver.fullname_id}
      overtime_line[:id] = driver.id
      #drivers_jobs = jobs.where( "jobs.driver_id = :driver_id or passengers.driver_id = :driver_id", driver_id: driver.id )
      overtime_line[:missing_days] = missing_days?( driver, jobs )
      overtime = get_overtime( driver, jobs )
      overtime_line[:total] = overtime["total"]
      overtime_line[:one] = overtime["one"]
      overtime_line[:one_and_half] = overtime["one_and_half"]
      overtime_line[:two] = overtime["two"]
      overtime_line[:minus] = overtime["minus"]
      overtime_line[:error] = overtime["error"]
      #abroad_line[:jobs] = drivers_jobs
      @overtimes << overtime_line
    end
    return @overtimes
  end

  def self.missing_days? driver, jobs, values = false
    job_day = DateTime.strptime( jobs.first.group_date + " 12:00", "%Y-%m-%d %H:%M")
    workdays = workdays( job_day )
    jobs.group_by(&:group_date).each do |date, job_group|
      jobs_with_driver = job_group.select{ |job| job.driver == driver || job.passengers.map(&:driver_id).include?( driver.id ) }
      unless jobs_with_driver.empty?
        day = DateTime.strptime( date + " 12:00", "%Y-%m-%d %H:%M")
        workdays.delete(day)
      end
    end
    if values
      return workdays
    else
      return workdays.empty?
    end
  end

  def self.workdays date
    workdays = []

    Time.days_in_month(2).times do |i|
      day = date.change( day: i + 1 )
      workdays << day unless day.sunday?
    end
    return workdays
  end

  def self.driver_total_overtime( driver, date )
    jobs = Job.eager_load(:passengers, :driver, :from, :to).where("actual_collection_time >= :time_start and " +
      "actual_collection_time < :time_end and ( jobs.driver_id = :driver_id or passengers.driver_id = :driver_id ) and status in (:status)",
      time_start: date.beginning_of_month, time_end: date.beginning_of_month + 1.month, driver_id: driver.id, status: [ Job::FINISHED, Job::CHARGED ] ).order(:actual_collection_time)
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
      overtime["total"] = 0
      overtime["one"] = 0
      overtime["one_and_half"] = 0
      overtime["two"] = 0
      overtime["minus"] = 0
      overtime["error"] = false
      calculations = {}
      jobs.group_by(&:group_date).each do |date, job_group|
        job_day = DateTime.strptime( date + " 12:00", "%Y-%m-%d %H:%M")
        daily_overtime, calculation = self.daily_overtime( job_day, job_group, driver )
        overtime["total"] += daily_overtime["total"]
        overtime["one"] += daily_overtime["one"]
        overtime["one_and_half"] += daily_overtime["one_and_half"]
        overtime["two"] += daily_overtime["two"]
        overtime["minus"] += daily_overtime["minus"]
        overtime["error"] = true if daily_overtime["error"]
        calculations[ date ] = calculation
      end
      overtime[ "missing_days" ] = missing_days? driver, jobs, true
      overtime["calculations"] = calculations
      overtime["jobs"] = jobs
      return overtime
    end

    def self.daily_overtime job_day, job_group, driver
      date = job_day.strftime( "%Y-%m-%d" )
      overtime = {}
      overtime["total"] = 0
      overtime["one"] = 0
      overtime["one_and_half"] = 0
      overtime["two"] = 0
      overtime["minus"] = 0
      overtime["error"] = false
      overtime["start"] = ""
      overtime["end"] = ""
      calculation = []
      return overtime, "" if job_group.nil?
      jobs_with_driver = job_group.select{ |job| job.driver == driver || job.passengers.map(&:driver_id).include?( driver.id ) }
      return overtime, "" if jobs_with_driver.empty?
      jobs_with_driver.sort_by!(&:actual_collection_time)

      # Doppelte Fahrten finden
      end_before = nil
      begin_after = nil
      indexes_to_remove = []
      jobs_with_driver.delete_if{ |job|
        if job.shuttle || job.co_drivers.empty?
          false
        else
          overlaping_jobs = jobs_with_driver.select{|single_job|
             !single_job.shuttle? && !single_job.co_drivers.empty? && ( single_job.actual_collection_time - job.actual_delivery_time ) *
             ( job.actual_collection_time - single_job.actual_delivery_time ) > 0
          }
          if overlaping_jobs.length == 1 # Because it overlaps itself
            false
          else
            main_driver_jobs = overlaping_jobs.select{ |single_job| driver.id == single_job.driver_id }
            if main_driver_jobs.length == 1
              if main_driver_jobs.first != job
              calculation << "Bei der Fahrt mit ID #{job.id} gibt es eine zeitgleiche Fahrt, der Hauptjob hat die ID #{main_driver_jobs.first.id} => Auftrag nicht in Berechnung"
                true
              else main_driver_jobs.first == job
                false
              end
            else
              other_jobs = overlaping_jobs.map(&:id)
              other_jobs.delete(job.id)
              calculation << "Die Fahrten mit den IDs #{other_jobs.join(",")} sind zeitgleich. Es konnte jedoch kein eindeutiger Hauptjob gefunden werden. Alle Fahrten sind weiterhin in der Berechnung."
              overtime["error"] = true
              false
            end
          end
        end
      }

      if job_day.sunday?
          jobs_with_driver.each_with_index do |single_job, i|
            calculation << "Fahrt #{i + 1} (ID: #{single_job.id}): #{single_job.from.show_address} - #{single_job.to.show_address} ( #{single_job.actual_collection_time.strftime('%H:%M')} - #{single_job.actual_delivery_time.strftime('%H:%M')})"
          end
          time_diff = TimeDifference.between( jobs_with_driver.first.actual_collection_time, jobs_with_driver.last.actual_delivery_time).in_hours
          overtime["total"] += time_diff * 2
          overtime["two"] += time_diff
          calculation << "#{time_diff} ( 2-fach ) ( Sonntagszuschlag ) = #{overtime["total"]}"
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

        jobs_with_driver.each_with_index do |job, i|
          calculation << "Fahrt #{i + 1} (ID: #{job.id}): #{job.from.show_address} - #{job.to.show_address} ( #{job.actual_collection_time.strftime('%H:%M')} - #{job.actual_delivery_time.strftime('%H:%M')})"
        end

        # Am Morgen

        job = jobs_with_driver.first
        if job.actual_collection_time < start_time_core
          if job.actual_collection_time < ( end_time_double - 1.day )
            time_diff = TimeDifference.between( start_time_core, ( end_time_double - 1.day )).in_hours
            overtime["total"] += time_diff
            overtime["one"] += time_diff
            calculation << "#{time_diff} ( 1-fach ) ( vor #{job_day.saturday? ? CORE_START_TIME_SATURDAY : CORE_START_TIME_WEEKDAY}" +
            "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
            time_diff = TimeDifference.between( (end_time_double - 1.day), job.actual_collection_time).in_hours
            overtime["total"] += time_diff * 2
            overtime["two"] += time_diff
            calculation << "#{time_diff} ( 2-fach ) ( vor #{OVERTIME_DOUBLE_END}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff * 2}"
          else
            time_diff = TimeDifference.between( start_time_core, job.actual_collection_time).in_hours
            overtime["total"] += time_diff
            overtime["one"] += time_diff
            calculation << "#{time_diff} ( 1-fach ) ( vor #{job_day.saturday? ? CORE_START_TIME_SATURDAY : CORE_START_TIME_WEEKDAY}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} ) = #{time_diff}"
          end
        elsif job.actual_collection_time > start_time_core
          time_diff = TimeDifference.between( start_time_core, job.actual_collection_time).in_hours
          overtime["total"] -= time_diff
          overtime["minus"] += time_diff
          calculation << "-#{time_diff} ( nach #{job_day.saturday? ? CORE_START_TIME_SATURDAY : CORE_START_TIME_WEEKDAY}" +
            "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
        end

      #Am Abend
        job = jobs_with_driver.last
        if job.actual_delivery_time > end_time_core
          if job.actual_delivery_time > start_time_double
            if job.actual_delivery_time > end_time_double
              time_diff = TimeDifference.between( start_time_double, end_time_core ).in_hours
              overtime["total"] += time_diff * 1.5
              overtime["one_and_half"] += time_diff
              calculation << "#{time_diff} ( 1-fach ) ( nach #{job_day.saturday? ? CORE_END_TIME_SATURDAY : CORE_END_TIME_WEEKDAY}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
              time_diff = TimeDifference.between( start_time_double, end_time_double).in_hours
              overtime["total"] += time_diff * 2
              overtime["two"] += time_diff
              calculation << "#{time_diff} x ( 2-fach ) ( nach #{OVERTIME_DOUBLE_START}" +
                "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
              time_diff = TimeDifference.between( end_time_double, job.actual_delivery_time ).in_hours
              overtime["total"] += time_diff
              overtime["one"] += time_diff
              calculation << "#{time_diff} ( 1-fach ) ( nach #{OVERTIME_DOUBLE_END}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} am Tag darauf ) = #{time_diff}"
            else
              time_diff = TimeDifference.between( start_time_double, end_time_core ).in_hours
              overtime["total"] += time_diff * 1.5
              overtime["one_and_half"] += time_diff
              calculation << "#{time_diff} ( 1 1/2-fach ) ( nach #{job_day.saturday? ? CORE_END_TIME_SATURDAY : CORE_END_TIME_WEEKDAY}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
              time_diff = TimeDifference.between( start_time_double, job.actual_delivery_time).in_hours
              overtime["total"] += time_diff * 2
              overtime["two"] += time_diff
              calculation << "#{time_diff} x 2 ( nach #{OVERTIME_DOUBLE_START}" +
                "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
            end
          else
            time_diff =  TimeDifference.between( end_time_core, jobs_with_driver.last.actual_delivery_time).in_hours
            overtime["total"] += time_diff * 1.5
            overtime["one_and_half"] += time_diff
            calculation << "#{time_diff} ( 1 1/2-fach ) ( nach #{job_day.saturday? ? CORE_END_TIME_SATURDAY : CORE_END_TIME_WEEKDAY}" +
              "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
          end
        elsif jobs_with_driver.last.actual_delivery_time < end_time_core
          time_diff =  TimeDifference.between( end_time_core, jobs_with_driver.last.actual_delivery_time).in_hours
          overtime["total"] -= time_diff
          overtime["minus"] += time_diff
          calculation << "-#{time_diff} ( vor #{job_day.saturday? ? CORE_END_TIME_SATURDAY : CORE_END_TIME_WEEKDAY}" +
            "#{job_day.saturday? ? " Samstags" : " Wochentags"} )"
        end
      end
      calculation << "=============================="
      calculation << "1-fache: #{overtime["one"]}"
      calculation << "1 1/2-fache: #{overtime["one_and_half"]}"
      calculation << "2-fache: #{overtime["two"]}"
      overtime["start"] = jobs_with_driver.first.actual_collection_time.strftime("%H:%M")
      overtime["end"] = jobs_with_driver.last.actual_delivery_time.strftime("%H:%M")
      return overtime, calculation
    end
end