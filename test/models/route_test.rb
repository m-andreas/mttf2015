require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  test "get correct addresses" do
    assert_equal addresses(:one), routes(:one).from
    assert_equal addresses(:two), routes(:one).to
  end
end
