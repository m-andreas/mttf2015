require 'test_helper'

class DriversControllerTest < ActionController::TestCase
  setup do
    @driver = drivers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:drivers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create driver" do
    assert_difference('Driver.count') do
      post :create, driver: { address: @driver.address, city: @driver.city, comment: @driver.comment, date_of_birth: @driver.date_of_birth, driving_licence_category: @driver.driving_licence_category, driving_licence_copy: @driver.driving_licence_copy, entry_date: @driver.entry_date, exit_date: @driver.exit_date, first_name: @driver.first_name, issuing_authority: @driver.issuing_authority, last_name: @driver.last_name, licence_number: @driver.licence_number, place_of_birth: @driver.place_of_birth, registration_copy: @driver.registration_copy, service_contract: @driver.service_contract, social_security_number: @driver.social_security_number, telephone2: @driver.telephone2, telepone: @driver.telepone, zip_code: @driver.zip_code }
    end

    assert_redirected_to driver_path(assigns(:driver))
  end

  test "should show driver" do
    get :show, id: @driver
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @driver
    assert_response :success
  end

  test "should update driver" do
    patch :update, id: @driver, driver: { address: @driver.address, city: @driver.city, comment: @driver.comment, date_of_birth: @driver.date_of_birth, driving_licence_category: @driver.driving_licence_category, driving_licence_copy: @driver.driving_licence_copy, entry_date: @driver.entry_date, exit_date: @driver.exit_date, first_name: @driver.first_name, issuing_authority: @driver.issuing_authority, last_name: @driver.last_name, licence_number: @driver.licence_number, place_of_birth: @driver.place_of_birth, registration_copy: @driver.registration_copy, service_contract: @driver.service_contract, social_security_number: @driver.social_security_number, telephone2: @driver.telephone2, telepone: @driver.telepone, zip_code: @driver.zip_code }
    assert_redirected_to driver_path(assigns(:driver))
  end

  test "should destroy driver" do
    assert_difference('Driver.count', -1) do
      delete :destroy, id: @driver
    end

    assert_redirected_to drivers_path
  end
end
