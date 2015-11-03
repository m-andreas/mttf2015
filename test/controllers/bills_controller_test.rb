require 'test_helper'

class BillsControllerTest < ActionController::TestCase
  setup do
    @bill = bills(:current)
    @user = users(:one)
    @old_bill = bills(:old_one)
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
    open_jobs_count = Job.where( status: Job::OPEN ).length + 1
    jobs(:one_no_date).actual_delivery_time = 1.day.ago.to_time
    jobs(:one_no_date).actual_collection_time = 1.day.ago.to_time
    jobs(:one_no_date).save
    post "add_jobs"
    assert_redirected_to current_bill_path
    assert assigns(:current_bill).is_current?
    assert_equal open_jobs_count, assigns(:current_bill).jobs.length
  end

  test "should not add open jobs to current bill" do
    sign_in @user
    post "add_jobs"
    open_jobs_count = Job.where( status: Job::OPEN ).length + 1
    assert_redirected_to current_bill_path
    assert flash[:error].present?
    assert_equal ["Die Werte für Abhol oder Lieferzeitpunkt sind nicht gesetz. Auftrag nicht verrechnet. Auftrag #{jobs(:one_no_date).id}".encode("ISO-8859-1")], flash[:error]
  end

  test "get_sixt_xls" do
    sign_in @user
    get "sixt_bill", { id: @old_bill, format: :xls }
    assert_response :success, flash[:error]
  end

  test "get_driver_xls" do
    sign_in @user
    get "drivers_bill", { id: @old_bill, format: :xls }
    assert_response :success, flash[:error]
  end

  test "get_complete_xls" do
    sign_in @user
    get "complete_bill", { id: @old_bill, format: :xls }
    assert_response :success, flash[:error]
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
    post :pay, id: @bill
    assert_redirected_to @bill
    assert Bill.get_current.jobs.empty?
    assert_not_nil assigns( :bill ).billed_at
    assigns( :bill ).jobs.each do |job|
      assert job.is_charged?
    end
  end

  test "should_not_set_bill_payed" do
    sign_in @user
    jobs( :payed_in_shuttle1 ).set_to_current_bill
    post :pay, id: @bill
    assert_redirected_to jobs_path
    @bill.reload
    assert_not Bill.get_current.jobs.empty?
    assert assigns( :bill ).billed_at.nil?
    assigns( :bill ).jobs.each do |job|
      assert job.is_finished?
    end
    assert flash[:alert].present?
  end

  test "should_not_set_bill_payed2" do
    sign_in @user
    jobs( :payed_shuttle ).set_to_current_bill
    post :pay, id: @bill
    assert_redirected_to jobs_path
    @bill.reload
    assert_not Bill.get_current.jobs.empty?
    assert assigns( :bill ).billed_at.nil?
    assigns( :bill ).jobs.each do |job|
      assert job.is_finished?
    end
    assert flash[:alert].present?
  end
end
