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
    assert_equal 1, jobs_billed = Job.where( status: Job::FINISHED ).length
    bill = Bill.get_current
    allready_in_bill = bill.jobs.length
    bill.add_jobs( jobs )
    bill.reload
    assert_equal 0, Job.get_open.length
    assert_equal jobs.length + allready_in_bill , bill.jobs.length

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

  test "set_current_bill_finished_with_missing_dependencys" do
    jobs(:shuttle).set_to_current_bill
    bill = Bill.get_current
    dependencies = bill.pay
    assert_equal 2, dependencies.length
    assert dependencies.first.is_a? String
    assert_not Bill.get_old.include? bill
    assert bill.is_current?
    bill.jobs.each do |job|
      assert job.is_finished?
    end
  end
end
