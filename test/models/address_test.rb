require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  test "get_active" do
     assert_equal 3, Address.get_active.length
  end

  test "get_full_address" do
    assert addresses(:one).get_full_address.is_a? String
  end
end
