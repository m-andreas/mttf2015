require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "get correct addresses" do
    assert_equal addresses(:one), jobs(:one).from
    assert_equal addresses(:two), jobs(:one).to
  end

  test "add_co_cobs" do
    assert_equal [ jobs(:one), jobs(:two) ], jobs(:shuttle).co_jobs
    jobs(:shuttle).add_co_jobs( "," + jobs(:one).id.to_s )
    assert_equal [jobs(:one) ], jobs(:shuttle).co_jobs
  end

  test "add_co_cobs_no_dash" do
    jobs(:shuttle).add_co_jobs( jobs(:one).id.to_s )
    assert_equal [jobs(:one) ], jobs(:shuttle).co_jobs
  end

  test "add_multible_co_jobs" do
    jobs(:shuttle).add_co_jobs( "," + jobs(:one).id.to_s + "," + jobs(:two).id.to_s )
    assert_equal [ jobs(:one), jobs(:two) ], jobs(:shuttle).co_jobs
  end

  test "dont_wirte_co_jobs_to_no_shuttle" do
    jobs(:two).add_co_jobs( "," + jobs(:one).id.to_s + "," + jobs(:shuttle).id.to_s )
    assert_equal [], jobs(:two).co_jobs
  end

  test "dont_wirte_yourself_to_shuttle" do
    jobs(:shuttle).add_co_jobs( "," + jobs(:shuttle).id.to_s )
    assert_equal [], jobs(:shuttle).co_jobs
  end

  test "delete_co_jobs_if_no_shuttle" do
    assert_equal [ jobs(:two) ], jobs(:one).co_jobs
    jobs(:one).add_co_jobs( "," + jobs(:two).id.to_s )
    assert_equal [], jobs(:one).co_jobs
  end

  test "is_shuttle" do
    assert jobs(:shuttle).is_shuttle?
    assert_not jobs(:one).is_shuttle?
  end

  test "get_shuttle_array" do
    assert [ [ jobs(:one).driver.fullname, jobs(:one).id ], [ jobs(:two).driver.fullname, jobs(:two).id ] ], jobs(:shuttle).get_shuttle_array
  end

  test "get_co_jobs_string" do
    assert_equal "," + jobs(:one).id.to_s + "," + jobs(:two).id.to_s, jobs(:shuttle).get_co_jobs_string
  end 

  test "must_have_driver_id" do
    job = Job.new
    assert_not job.valid?
    assert_equal [:driver_id, :status], job.errors.keys
  end
end
