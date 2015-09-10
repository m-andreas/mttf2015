require 'test_helper'

class CarrierTest < ActiveSupport::TestCase

  test "driver with many" do
    assert_equal drivers(:one), jobs(:one).driver
    assert_equal [ drivers(:exit_nil), drivers(:entered_today) ], jobs(:one).co_drivers
  end

  test "single driver" do
    assert_equal drivers(:one), jobs(:two).driver
    assert_equal [ ], jobs(:two).co_drivers
  end
end
