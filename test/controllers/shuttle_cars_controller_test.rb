require 'test_helper'

class ShuttleCarsControllerTest < ActionController::TestCase
  setup do
    @shuttle_car = shuttle_cars(:one)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:shuttle_cars)
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create shuttle_car" do
    sign_in @user
    assert_difference('ShuttleCar.count') do
      post :create, shuttle_car: { car_brand: @shuttle_car.car_brand, car_type: @shuttle_car.car_type, registration_number: @shuttle_car.registration_number }
    end

    assert_redirected_to shuttle_car_path(assigns(:shuttle_car))
  end

  test "should show shuttle_car" do
    sign_in @user
    get :show, id: @shuttle_car
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @shuttle_car
    assert_response :success
  end

  test "should update shuttle_car" do
    sign_in @user
    patch :update, id: @shuttle_car, shuttle_car: { car_brand: @shuttle_car.car_brand, car_type: @shuttle_car.car_type, registration_number: @shuttle_car.registration_number }
    assert_redirected_to shuttle_car_path(assigns(:shuttle_car))
  end

  test "should destroy shuttle_car" do
    sign_in @user
    assert_difference('ShuttleCar.count', -1) do
      delete :destroy, id: @shuttle_car
    end

    assert_redirected_to shuttle_cars_path
  end
end
