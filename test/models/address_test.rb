require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  test "get_active" do
     assert_equal 4, Address.get_active.length
  end

  test "get_full_address" do
    assert addresses(:one).complete_address.is_a? String
  end

  test "show address" do
  	assert_equal "Mondstrasse Wien", addresses(:one).show_address
	addresses(:one).display_name = "Mond"
	addresses(:one).save
  	assert_equal "Mond", addresses(:one).show_address
  end
end
