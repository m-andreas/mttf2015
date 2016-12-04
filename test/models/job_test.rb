require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "get correct addresses" do
    assert_equal addresses(:one), jobs(:one).from
    assert_equal addresses(:two), jobs(:one).to
  end

  test "is_shuttle" do
    assert jobs(:shuttle).is_shuttle?
    assert_not jobs(:one).is_shuttle?
  end

  test "must_have_driver_id" do
    job = Job.new
    assert_not job.valid?
    assert_equal [:status], job.errors.keys
  end

  test "change job to shuttle" do
    jobs(:one).set_shuttle
    assert_nil jobs(:one).driver_id
    assert_equal [1], jobs(:one).get_shuttle_data.legs.first["driver_ids"]
    assert_equal 2, jobs(:one).get_shuttle_data.stops.length
    assert_equal 1, jobs(:one).get_shuttle_data.legs.length
    assert jobs(:one).is_shuttle?
    assert_nil jobs(:one).driver_id
  end

  test "change job with_co_drivers to shuttle" do
    jobs(:with_co_drivers).set_shuttle
    assert_nil jobs(:with_co_drivers).driver_id
    assert jobs(:with_co_drivers).get_shuttle_data.legs.first["driver_ids"].include? 1
    assert jobs(:with_co_drivers).get_shuttle_data.legs.first["driver_ids"].include? 2
    assert jobs(:with_co_drivers).get_shuttle_data.legs.first["driver_ids"].include? 3
    assert_equal 2, jobs(:with_co_drivers).get_shuttle_data.stops.length
    assert_equal 1, jobs(:with_co_drivers).get_shuttle_data.legs.length
    assert jobs(:with_co_drivers).is_shuttle?
    assert_nil jobs(:with_co_drivers).driver_id
  end

  test "remove passenger" do
    jobs(:shuttle).remove_shuttle_passenger drivers(:one), 1
    assert_equal [3], jobs(:shuttle).get_shuttle_data.legs.second["driver_ids"]
    assert !Passenger.where(job:jobs(:shuttle), driver: drivers(:one)).empty?
    jobs(:shuttle).remove_shuttle_passenger drivers(:one), 0
    assert_equal [], jobs(:shuttle).get_shuttle_data.legs.first["driver_ids"]
    assert Passenger.where(job:jobs(:shuttle), driver: drivers(:one)).empty?
  end

  test "remove_shuttles" do
    assert_equal 4, jobs(:shuttle).stops.length
    jobs(:shuttle).remove_shuttles
    jobs(:shuttle).reload
    assert jobs(:shuttle)[:shuttle_data].nil?
  end

  test "check for billing no route" do
    jobs(:one).route_id = nil
    jobs(:one).save
    jobs(:one).check_for_billing
    assert !jobs(:one).route_id.nil?
    assert jobs(:one).is_open?
  end

  test "check for billing no addresses" do
    jobs(:one).route_id = nil
    jobs(:one).from_id = nil
    jobs(:one).to_id = nil
    jobs(:one).save
    jobs(:one).check_for_billing
    assert jobs(:one).is_open?
  end

  test "check for billing not finished shuttle" do
    jobs(:not_finished_shuttle).bill_id = nil
    jobs(:not_finished_shuttle).status = Job::OPEN
    jobs(:not_finished_shuttle).save
    assert_equal ( I18n.translate("jobs.not_billed_not_all_stops_present") + jobs(:not_finished_shuttle).id.to_s ),
      jobs(:not_finished_shuttle).check_for_billing
    assert jobs(:not_finished_shuttle).is_open?
      jobs(:not_finished_shuttle).bill_id = bills(:store)
    jobs(:not_finished_shuttle).status = Job::CHARGED
    jobs(:not_finished_shuttle).save
  end

  test "get_route_string" do
    assert_equal "Graz -  - Graz - Graz", jobs(:shuttle).get_route_string
  end

  test "get_abroad_time" do
    assert_equal 4, jobs(:one).get_abroad_time(jobs(:one).driver)
  end

  test "get_abroad_time_empty" do
    assert_equal 0, jobs(:one_no_date).get_abroad_time(jobs(:one_no_date).driver)
  end

  test "get_abroad_time_shuttle" do
    assert_equal 1.5, jobs(:shuttle).get_abroad_time(drivers(:three))
  end

  test "get_abroad_time_not_in_shuttle" do
    assert_equal 0, jobs(:shuttle).get_abroad_time(drivers(:entered_today))
  end

  test "monthly_abroad_time" do
    assert_equal 5.5, AbroadTime.driver_total_abroad_time( drivers(:one), Time.now )
  end

  test "monthly_abroad_time_to_low" do
    if Date.today == Date.today.beginning_of_month
      jobs(:with_co_drivers_abroad).actual_collection_time = 2.day.from_now
    else
      jobs(:with_co_drivers_abroad).actual_collection_time = 1.day.ago
    end
    jobs(:with_co_drivers_abroad).abroad_time_start= "12:00".to_time
    jobs(:with_co_drivers_abroad).save
    assert_equal 3, AbroadTime.driver_total_abroad_time( drivers(:one), Time.now )
  end
end
