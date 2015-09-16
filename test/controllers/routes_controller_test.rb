require 'test_helper'

class RoutesControllerTest < ActionController::TestCase
  setup do
    @route = routes(:one)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:routes)
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create route" do
    sign_in @user
    assert_difference('Route.count') do
      post :create, route: { calculation_basis: @route.calculation_basis, from_id: @route.from_id, distance: @route.distance, status: @route.status, to_id: @route.to_id }
    end
    assert_redirected_to route_path(assigns(:route))
  end

  test "should show route" do
    sign_in @user
    get :show, id: @route
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @route
    assert_response :success
  end

  test "should update route" do
    sign_in @user
    patch :update, id: @route, route: { calculation_basis: @route.calculation_basis, from_id: @route.from_id, distance: @route.distance, status: @route.status, to_id: @route.to_id }
    assert_redirected_to new_routes_path
  end

  test "should destroy route" do
    sign_in @user
    count_old = Route.get_active.count
    delete :destroy, id: @route
    assert_equal count_old - 1, Route.get_active.count
    assert_redirected_to routes_path
  end
end
