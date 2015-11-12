require 'test_helper'

class CarrierTest < ActiveSupport::TestCase

  test "job with co_jobs" do
    assert_equal drivers(:one), jobs(:one).driver
    assert_equal [ drivers(:one), drivers(:entered_today) ], jobs(:shuttle).co_job_drivers
  end

  test "single driver" do
    assert_equal drivers(:entered_today), jobs(:two).driver
    assert_equal [ ], jobs(:two).co_job_drivers
  end
end
