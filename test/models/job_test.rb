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

  test "add_co_cobs 2 times" do
    assert_equal [ jobs(:one), jobs(:two) ], jobs(:shuttle).co_jobs
    jobs(:shuttle).add_co_jobs( "," + jobs(:one).id.to_s )
    assert_equal [jobs(:one) ], jobs(:shuttle).co_jobs
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
    Carrier.create(job_id: jobs(:one).id, co_job_id: jobs(:two).id)
    assert_equal [ jobs(:two) ], jobs(:one).co_jobs
    jobs(:one).add_co_jobs( "," + jobs(:two).id.to_s )
    assert_equal [], jobs(:one).co_jobs
  end

  test "is_shuttle" do
    assert jobs(:shuttle).is_shuttle?
    assert_not jobs(:one).is_shuttle?
  end

  test "has_shuttle" do
    assert_not jobs(:shuttle).has_shuttle?
    assert_not jobs(:not_in_shuttle).has_shuttle?
    assert jobs(:one).has_shuttle?
  end

  test "get_shuttle_job" do
    assert jobs(:shuttle).shuttle_job.nil?
    assert jobs(:not_in_shuttle).shuttle_job.nil?
    assert_equal jobs(:shuttle), jobs(:two).shuttle_job
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
    assert_equal [:status], job.errors.keys
  end

  test "set_breakpoints" do
    jobs(:shuttle).breakpoints = []
    jobs(:shuttle).add_breakpoints
    assert_equal 2, jobs(:shuttle).breakpoints.length
    assert jobs(:shuttle).breakpoints.first.address jobs(:two).from
  end

  test "remove_shuttles" do
    assert_equal 2, jobs(:shuttle).carriers.length
    jobs(:shuttle).remove_shuttles
    jobs(:shuttle).reload
    assert jobs(:shuttle).carriers.empty?
  end

  test "remove_co_job" do
    assert_equal 2, jobs(:shuttle).carriers.length
    jobs(:shuttle).remove_co_job( jobs(:shuttle).co_jobs.first )
    assert_equal 1, jobs(:shuttle).carriers.length
  end

  test "check_shuttle_dependencies" do
    jobs(:shuttle).set_to_current_bill
    jobs(:one).set_to_current_bill
    jobs(:two).set_to_current_bill
    missing_dependencys = Bill.get_current.pay
    jobs(:shuttle).reload
    jobs(:one).reload
    jobs(:two).reload
    assert jobs(:shuttle).is_charged?, missing_dependencys
    assert jobs(:one).is_charged?
    assert jobs(:two).is_charged?
  end

  test "check_shuttle_dependencies_fail" do
    jobs(:shuttle).set_to_current_bill
    jobs(:one).set_to_current_bill
    Bill.get_current.pay
    jobs(:shuttle).reload
    jobs(:one).reload
    jobs(:two).reload
    assert jobs(:shuttle).is_finished?
    assert jobs(:one).is_finished?
    assert jobs(:two).is_open?
  end

  test "check_shuttle_dependencies_fail2" do
    jobs(:two).set_to_current_bill
    jobs(:one).set_to_current_bill
    Bill.get_current.pay
    jobs(:shuttle).reload
    jobs(:one).reload
    jobs(:two).reload
    assert jobs(:shuttle).is_open?
    assert jobs(:one).is_finished?
    assert jobs(:two).is_finished?
  end
end
