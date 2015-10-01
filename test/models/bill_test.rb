require 'test_helper'

class BillTest < ActiveSupport::TestCase

  test "get_current" do
    assert 1, Bill.get_current.present?
    b = Bill.get_current
    b.destroy
    assert 1, Bill.get_current.present?
  end

  test "get_old" do
    assert_equal 2, Bill.get_old.length
  end

  test "create_bill_from_current_jobs" do
    jobs = Job.get_open
    assert_equal 0, jobs_billed = Job.where( status: Job::FINISHED ).length
    bill = Bill.get_current
    bill.add_jobs( jobs )

    assert_equal 0, Job.get_open.length
    assert_equal jobs.length, bill.jobs.length

    bill.jobs.each do |job|
      assert job.is_finished?
    end
  end

  test "is_old" do
    assert bills( :old_one ).is_old?
    assert_not bills( :current ).is_old?
  end

  test "is_current" do
    assert_not bills( :old_one ).is_current?
    assert bills( :current ).is_current?
  end

  test "set_current_bill_finished" do
    bill = Bill.get_current
    bill.pay

    assert Bill.get_old.include? bill
    assert bill.is_old?
    bill.jobs.each do |job|
      assert job.is_charged?
    end
  end
end
