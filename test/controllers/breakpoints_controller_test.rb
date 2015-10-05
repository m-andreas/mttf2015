require 'test_helper'

class BreakpointsControllerTest < ActionController::TestCase
  setup do
    @breakpoint = breakpoints(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:breakpoints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create breakpoint" do
    assert_difference('Breakpoint.count') do
      post :create, breakpoint: { distance: @breakpoint.distance, job_id: @breakpoint.job_id, position: @breakpoint.position }
    end

    assert_redirected_to breakpoint_path(assigns(:breakpoint))
  end

  test "should show breakpoint" do
    get :show, id: @breakpoint
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @breakpoint
    assert_response :success
  end

  test "should update breakpoint" do
    patch :update, id: @breakpoint, breakpoint: { distance: @breakpoint.distance, job_id: @breakpoint.job_id, position: @breakpoint.position }
    assert_redirected_to breakpoint_path(assigns(:breakpoint))
  end

  test "should destroy breakpoint" do
    assert_difference('Breakpoint.count', -1) do
      delete :destroy, id: @breakpoint
    end

    assert_redirected_to breakpoints_path
  end
end
