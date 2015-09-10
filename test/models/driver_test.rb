require 'test_helper'

class DriverTest < ActiveSupport::TestCase
  test "amount of active drivers" do
    assert_equal 3, Driver.get_active.length
  end
  # test "the truth" do
  #   assert true
  # end
end
