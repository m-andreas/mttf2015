require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  test "get correct addresses" do
    assert_equal addresses(:one), routes(:one).from
    assert_equal addresses(:two), routes(:one).to
  end

  test "Route allready exists" do
    assert_no_difference('Route.count') do
      route_id = Route.find_or_create( addresses( :one ).id, addresses(:two).id)
      assert_equal routes(:one).id, route_id
    end
  end

  test "Route doesnt exists" do
    assert_difference('Route.count') do
      route_id = Route.find_or_create( addresses( :two ), addresses(:three))
      assert route_id.is_a? Integer
    end
  end
end
