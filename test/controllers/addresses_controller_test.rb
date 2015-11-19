require 'test_helper'

class AddressesControllerTest < ActionController::TestCase
  setup do
    @address = addresses(:one)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:addresses)
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create address" do
    sign_in @user
    assert_difference('Address.count') do
      post :create, address: { address: @address.address, address_short: @address.address_short, city: @address.city, country: @address.country, created_by: @address.created_by, inactive: @address.inactive, zip_code: @address.zip_code }
    end

    assert_redirected_to address_path(assigns(:address))
  end

  test "should show address" do
    sign_in @user
    get :show, id: @address
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @address
    assert_response :success
  end

  test "should update address" do
    sign_in @user
    patch :update, id: @address, address: { address: @address.address, address_short: @address.address_short, city: @address.city, country: @address.country, created_by: @address.created_by, inactive: @address.inactive, zip_code: @address.zip_code }
    assert_redirected_to address_path(assigns(:address))
  end

  test "should destroy address" do
    sign_in @user
    assert_difference('Address.get_active.count', -1) do
      delete :destroy, id: @address
    end

    assert_redirected_to addresses_path
  end
end
