require 'test_helper'

class BillsControllerTest < ActionController::TestCase
  setup do
    @bill = bills(:current)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:bills)
  end

  test "should get current" do
    sign_in @user
    get :current
    assert_response :success
    assert_not_nil assigns(:bill)
  end

  test "should get old" do
    sign_in @user
    get :old
    assert_response :success
    assert_not_nil assigns(:bills)
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should add open jobs to current bill" do
    sign_in @user
    post "add_jobs"
    assert_redirected_to current_bill_path
    assert assigns(:current_bill).is_current?
    assert_not_nil assigns(:current_bill).jobs
  end

  test "should create bill" do
    sign_in @user
    assert_difference('Bill.count') do
      post :create, bill: { print_date: @bill.print_date }
    end
    assert_nil assigns( :bill ).billed_at
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
    patch :update, id: @bill, bill: { print_date: @bill.print_date }
    assert_redirected_to @bill
  end

  test "should destroy bill" do
    sign_in @user
    assert_difference('Bill.count', -1) do
      delete :destroy, id: bills( :old_one )
    end
    assert jobs(:payed).is_finished?
    assert_equal Bill.get_current, jobs(:payed).bill
    assert_redirected_to current_bill_path
  end

  test "should remove current bill" do
    sign_in @user
    assert_equal 1, Bill.get_current.jobs.length
    post :delete_current
    assert_redirected_to jobs_path
    assert_nil jobs(:finished).bill
    assert jobs(:finished).is_open?
  end

  test "should set bill payed" do
    sign_in @user
    puts "set bill payed"
    puts @bill.jobs.inspect
    post :pay, id: @bill
    assert_redirected_to @bill
    assert Bill.get_current.jobs.empty?
    assert_not_nil assigns( :bill ).billed_at
    assigns( :bill ).jobs.each do |job|
      assert job.is_charged?
    end
  end
end
