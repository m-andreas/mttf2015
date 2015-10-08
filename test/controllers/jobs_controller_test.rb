require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  setup do
    @job = jobs(:one)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
  end

  test "should get redirected" do
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create job" do
    sign_in @user
    assert_difference('Job.count') do
      post :create, job: { cost_center_id: @job.cost_center_id, from_id: routes(:one).from_id, driver_id: drivers(:one).id, shuttle: false, to_id: routes(:one).to_id,
        car_brand: "BMW", car_type: "Z4", registration_number: "W123",
        scheduled_collection_date: "2015-02-02", scheduled_delivery_date: "2015-02-02", chassis_number: "123", mileage_delivery: "100000",
        mileage_collection: "200000", job_notice: "job_notice", transport_notice: "transport_notice", transport_notice_extern: "transport_notice_extern"},
        co_jobs: ""
    end
    assert_equal users(:one), assigns(:job).created_by
    assert_equal routes(:one), assigns(:job).route
    assert_equal drivers(:one), assigns(:job).driver
    assert_equal "BMW", assigns(:job).car_brand
    assert_equal "Z4", assigns(:job).car_type
    assert_equal "W123", assigns(:job).registration_number
    assert_equal "2015-02-02".to_date, assigns(:job).scheduled_collection_date
    assert_equal "2015-02-02".to_date, assigns(:job).scheduled_delivery_date
    assert_equal "2015-02-02".to_date, assigns(:job).actual_collection_date
    assert_equal "2015-02-02".to_date, assigns(:job).actual_delivery_date
    assert_equal "123", assigns(:job).chassis_number
    assert_equal  100000, assigns(:job).mileage_delivery
    assert_equal  200000, assigns(:job).mileage_collection
    assert_equal "job_notice", assigns(:job).job_notice
    assert_equal "transport_notice", assigns(:job).transport_notice
    assert_equal "transport_notice_extern", assigns(:job).transport_notice_extern
    assert_redirected_to jobs_path)
    assert !assigns(:job).shuttle
    assert_equal @job.cost_center_id, assigns(:job).cost_center_id
  end

  test "should create job with co job" do
    sign_in @user
    post :create, job: { cost_center_id: @job.cost_center_id, from_id: routes(:one).from_id, driver_id: drivers(:one).id, shuttle: true, to_id: routes(:one).to_id,
      car_brand: "BMW", car_type: "Z4", registration_number: "W123",
      scheduled_collection_date: "2015-02-02", scheduled_delivery_date: "2015-02-02", chassis_number: "123", mileage_delivery: "100000",
      mileage_collection: "200000", job_notice: "job_notice", transport_notice: "transport_notice", transport_notice_extern: "transport_notice_extern"},
      co_jobs: ",#{jobs(:one).id}, #{jobs(:two).id}"
    job = Job.find(assigns(:job).id)
    assert_equal jobs(:two), job.co_jobs.first
    assert_equal jobs(:one), job.co_jobs.last
    assert_equal 2, job.co_jobs.length
    assert_equal 1, job.breakpoints.length
    assert_equal jobs(:one).from, job.breakpoints.first.address
  end

  test "should show job" do
    sign_in @user
    get :show, id: @job
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @job
    assert_response :success
  end

  test "should update job" do
    sign_in @user
    date = Date.current
    patch :update, id: @job, subaction: "update", job: { actual_collection_date: date, actual_delivery_date: date, cost_center_id: @job.cost_center_id, created_by_id: @job.created_by_id, driver_id: @job.driver_id, status: @job.status, from_id: @job.from_id, route_id: @job.route_id, shuttle: @job.shuttle, to_id: @job.to_id }
    assert_redirected_to jobs_path
    assert_equal date, assigns(:job).actual_collection_date
    assert_equal date, assigns(:job).actual_delivery_date
  end

  test "should update job and set to current" do
    sign_in @user
    date = Date.current
    patch :update, id: @job, subaction: "update_and_pay", job: { actual_collection_date: date, actual_delivery_date: date, cost_center_id: @job.cost_center_id, created_by_id: @job.created_by_id, driver_id: @job.driver_id, status: @job.status, from_id: @job.from_id, route_id: @job.route_id, shuttle: @job.shuttle, to_id: @job.to_id }
    assert_redirected_to jobs_path
    assert @job.reload
    assert @job.is_finished?
    assert_equal date, assigns(:job).actual_collection_date
    assert_equal date, assigns(:job).actual_delivery_date
  end

  test "should destroy job" do
    sign_in @user
    assert_difference('Job.get_active.count', -1) do
      delete :destroy, id: @job
    end

    assert_redirected_to jobs_path
  end

  test "set_to_current_bill" do
    sign_in @user
    post :add_to_current_bill, id: jobs(:one)
    jobs(:one).reload
    assert jobs(:one).is_finished?
    assert_equal Bill.get_current, jobs(:one).bill
    assert_redirected_to jobs_path
  end

  test "remove_from_current_bill" do
    sign_in @user
    post :remove_from_current_bill, id: jobs(:finished)
    jobs(:finished).reload
    assert jobs(:finished).is_open?
    assert_nil jobs(:finished).bill
    assert_redirected_to jobs_path
  end

  test "add_co_driver" do
    sign_in @user
    assert_equal 0, jobs(:empty_shuttle).co_drivers.length
    post :add_co_driver, id: jobs(:empty_shuttle), co_job_id: jobs( :one ).id
    jobs(:empty_shuttle).reload
    assert_equal 1, jobs(:empty_shuttle).co_drivers.length
  end

  test "remove_co_driver" do
    sign_in @user
    assert_equal 2, jobs(:shuttle).co_drivers.length
    post :remove_co_driver, id: jobs(:shuttle), co_job_id: jobs( :two ).id
    shuttle = Job.find(jobs(:shuttle).id)
    puts "carrieres in test"
    puts shuttle.carriers.inspect
    assert_equal 1, shuttle.co_drivers.length
    assert_equal [jobs(:one)], shuttle.co_jobs
  end
end
