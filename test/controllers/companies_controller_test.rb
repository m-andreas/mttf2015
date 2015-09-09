require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase
  setup do
    @company = companies(:one)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:companies)
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create company" do
    sign_in @user
    assert_difference('Company.count') do
      post :create, company: { address: @company.address, city: @company.city, country: @company.country, email: @company.email, name: @company.name, price_flat_rate: @company.price_flat_rate, price_per_km: @company.price_per_km, telephone: @company.telephone, zip_code: @company.zip_code }
    end

    assert_redirected_to company_path(assigns(:company))
  end

  test "should show company" do
    sign_in @user
    get :show, id: @company
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @company
    assert_response :success
  end

  test "should update company" do
    sign_in @user
    patch :update, id: @company, company: { address: @company.address, city: @company.city, country: @company.country, email: @company.email, name: @company.name, price_flat_rate: @company.price_flat_rate, price_per_km: @company.price_per_km, telephone: @company.telephone, zip_code: @company.zip_code }
    assert_redirected_to company_path(assigns(:company))
  end

  test "should destroy company" do
    sign_in @user
    assert_difference('Company.count', -1) do
      delete :destroy, id: @company
    end

    assert_redirected_to companies_path
  end
end
