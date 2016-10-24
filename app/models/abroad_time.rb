class AbroadTime
  MIN_TIME = 8

  def self.get_times_per_month date
    jobs = Job.eager_load(:passengers, :driver, :from, :to).where("(shuttle = false and actual_collection_time >= :time_start and " +
      "actual_collection_time <= :time_end and status in (:status) AND abroad_time_start IS NOT NULL AND " +
      "abroad_time_end IS NOT NULL AND abroad_time_start != '' AND " +
      "abroad_time_end != '') OR (shuttle = true and actual_collection_time >= :time_start and " +
      "actual_collection_time <= :time_end and status in (:status))",
      time_start: date.beginning_of_month, time_end: date.end_of_month, status: [ Job::FINISHED, Job::CHARGED ] )
    @abroad_times = []
    drivers = []
    jobs_no_empty = jobs.reject { |j| j.shuttle? && j.get_abroad_time == 0 }
    puts jobs_no_empty.inspect
    jobs_no_empty.each do |job|
      drivers << job.driver unless job.driver.nil?
      job.passengers.each do |passenger|
        drivers << passenger.driver
      end
    end

    drivers.uniq!
    drivers = drivers.sort_by{|e| e[:id]}
    drivers.each do |driver|
      drivers_jobs = []
      abroad_line = {name: driver.fullname_id}
      abroad_line[:id] = driver.id
      drivers_jobs = jobs.where( "jobs.driver_id = :driver_id or passengers.driver_id = :driver_id", driver_id: driver.id )
      abroad_line[:time] = get_abroad_time_for_jobs( driver, drivers_jobs )
      #abroad_line[:jobs] = drivers_jobs
      @abroad_times << abroad_line
    end
    return @abroad_times
  end

  def self.driver_total_abroad_time( driver, date, with_jobs = false )
    jobs = Job.eager_load(:passengers).where("(shuttle = false and actual_collection_time >= :time_start and " +
      "actual_collection_time <= :time_end and jobs.driver_id = :driver_id and status in (:status) AND " +
      "abroad_time_start IS NOT NULL AND abroad_time_end IS NOT NULL AND abroad_time_start != '' AND " +
      "abroad_time_end != '') or " +
      "( passengers.driver_id = :driver_id and status in (:status) )",
      time_start: date.beginning_of_month, time_end: date.end_of_month, driver_id: driver.id, status: [ Job::FINISHED, Job::CHARGED ] )
    if with_jobs
      return get_abroad_time_for_jobs( driver, jobs ), jobs
    else
      return get_abroad_time_for_jobs driver, jobs
    end
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
    def self.get_abroad_time_for_jobs driver, jobs
      total_time = 0

      jobs.group_by(&:group_date).each do |date, job_group|
        day_abroad_time = 0
        job_group.each do |job|
          day_abroad_time += job.get_abroad_time(driver)
        end
        total_time += day_abroad_time if day_abroad_time >= MIN_TIME
      end
      return total_time
    end
end