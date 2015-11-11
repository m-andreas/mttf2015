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

  test "Route allready exists turned arround" do
    assert_equal Route.find_or_create(4,3), Route.find_or_create(3,4)
  end

  test "Route doesnt exists" do
    assert_difference('Route.count') do
      route_id = Route.find_or_create( addresses( :two ), addresses(:three))
      assert route_id.is_a? Integer
    end
  end

  test "set_route_stati" do
    route = routes(:not_confirmed)
    assert route.is_new?
    route.set_processed
    route.reload
    assert route.is_active?
    route.delete
    route.reload
    assert route.is_deleted?
    route.set_new
    assert route.is_new?
  end

  test "ask_for_deleted_route" do
    assert routes(:deleted).is_deleted?
    assert_no_difference('Route.count') do
      route_id = Route.find_or_create( addresses( :four ).id, addresses(:one).id)
      assert_equal routes(:deleted).id, route_id
      assert Route.find(route_id).is_new?
    end
  end

  test "get new routes" do
    new_routes = Route.get_new
    assert_equal [routes(:not_confirmed)], new_routes
  end
end
