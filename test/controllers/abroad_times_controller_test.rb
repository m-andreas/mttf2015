#encoding: utf-8
require 'test_helper'

class AbroadTimesControllerTest < ActionController::TestCase
  setup do
    @job = jobs(:one)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
  end

  test "should show month" do
    sign_in @user
    get :show, month_string: "september_2016"
    assert_equal "1.9.2016".to_date, assigns(:date)
    assert_response :success
  end

  test "should show user" do
    sign_in @user
    get :show_driver, date: Date.today, driver_id: drivers(:one).id
    assert_equal 5.5, assigns(:total_time)
    assert_equal 3, assigns(:jobs).length
    assert_response :success
  end

end
