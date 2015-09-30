require 'test_helper'

class BillsControllerTest < ActionController::TestCase
  setup do
    @bill = bills(:one)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:bills)
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create bill" do
    sign_in @user
    assert_difference('Bill.count') do
      post :create, bill: { billed_at: @bill.billed_at, print_date: @bill.print_date }
    end

    assert_redirected_to bill_path(assigns(:bill))
  end

  test "should show bill" do
    sign_in @user
    get :show, id: @bill
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @bill
    assert_response :success
  end

  test "should update bill" do
    sign_in @user
    patch :update, id: @bill, bill: { billed_at: @bill.billed_at, print_date: @bill.print_date }
    assert_redirected_to bill_path(assigns(:bill))
  end

  test "should destroy bill" do
    sign_in @user
    assert_difference('Bill.count', -1) do
      delete :destroy, id: @bill
    end

    assert_redirected_to bills_path
  end
end
