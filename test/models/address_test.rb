require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  test "get_active" do
     assert_equal 3, Address.get_active.length
  end
end
