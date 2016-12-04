require 'test_helper'

class BillTest < ActiveSupport::TestCase

  test "get_current" do
    assert 1, Bill.get_current.present?
    b = Bill.get_current
    b.destroy
    assert 1, Bill.get_current.present?
  end

  test "get_old" do
    assert_equal 3, Bill.get_old.length
  end

  test "create_bill_from_current_jobs" do
    jobs = Job.get_open
    assert_equal 1, jobs_billed = Job.where( status: Job::FINISHED ).where.not( bill: bills(:abroad)).length
    bill = Bill.get_current
    allready_in_bill = bill.jobs.length
    jobs.delete(jobs(:one_no_date))
    jobs.delete(jobs(:one_no_driver))
    messages = bill.add_jobs( jobs )
    bill.reload
    assert_equal 0, Job.get_open.length, messages.inspect
    assert_equal jobs.length + allready_in_bill , bill.jobs.length, messages.inspect

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

  test "check shuttle values" do
    bill = Bill.get_current
    jobs(:shuttle).set_to_current_bill
    bill.pay
    payment_sixt = ( 300 + 100 )* 0.24
    payment_driver1 = 100 * 0.072 + 100 * 0.072 + 50 * 0.072 / 2
    payment_driver2 = 150 * 0.072 / 2
    payment_driver3 = 50 * 0.072 / 2 + 150 * 0.072 / 2
    assert_equal payment_sixt, bill.sixt_total
    assert_equal payment_driver1, bill.driver_total( drivers(:one) )
    assert_equal payment_driver2.round(2), bill.driver_total( drivers(:two) ).round(2)
    assert_equal payment_driver3.round(2), bill.driver_total( drivers(:three) ).round(2)
  end

  test "get_sixt_price_for_current" do
    bill = Bill.get_current
    jobs(:shuttle).set_to_current_bill
    jobs(:one).set_to_current_bill
    jobs(:two).set_to_current_bill
    bill.reload
    payment_sixt = 500 * 0.24 + 19
    assert_equal payment_sixt.round(2), bill.sixt_total.round(2)
  end

  test "get job price for shuttle without breakpoints" do
    jobs(:finished).set_shuttle
    jobs(:finished).save
    bill = Bill.get_current
    dependencies = bill.pay
    assert_equal ( 100 * 0.072 ).round(2).to_s, bill.driver_total( drivers(:one) ).to_s
    assert dependencies
  end

  test "get drivers when co_drivers" do
    jobs(:finished).add_co_driver( drivers(:two) )
    jobs(:finished).add_co_driver( drivers(:three) )
    bill = Bill.get_current
    dependencies = bill.pay
    assert dependencies
    assert_equal 3, bill.drivers.length
    assert_equal (( 100 * 0.072 )/3).round(2).to_s, bill.driver_total( drivers(:one) ).to_s
  end

  test "get drivers for co_driver" do
    jobs(:finished).add_co_driver( drivers(:two) )
    jobs(:finished).add_co_driver( drivers(:three) )
    bill = Bill.get_current
    dependencies = bill.pay
    assert dependencies
    assert_equal [jobs(:finished)], bill.get_drives( drivers(:one) )
    assert_equal [jobs(:finished)], bill.get_drives( drivers(:two) )
    assert_equal [jobs(:finished)], bill.get_drives( drivers(:three) )
    assert_equal [jobs(:finished).id], bill.get_drives_array( drivers(:one) )
    assert_equal [jobs(:finished).id], bill.get_drives_array( drivers(:two) )
    assert_equal [jobs(:finished).id], bill.get_drives_array( drivers(:three) )  end
end
