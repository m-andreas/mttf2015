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

  test "get_route_string" do
    assert_equal "Graz -  - Graz - Graz", jobs(:shuttle).get_route_string
  end
end
