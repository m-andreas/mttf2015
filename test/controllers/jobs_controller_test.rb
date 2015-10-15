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
        scheduled_collection_time: "2015-02-02", scheduled_delivery_time: "2015-02-02", chassis_number: "123", mileage_delivery: "100000",
        mileage_collection: "200000", job_notice: "job_notice", transport_notice: "transport_notice", transport_notice_extern: "transport_notice_extern"},
        co_jobs: ""
    end
    assert_equal users(:one), assigns(:job).created_by
    assert_equal routes(:one), assigns(:job).route
    assert_equal drivers(:one), assigns(:job).driver
    assert_equal "BMW", assigns(:job).car_brand
    assert_equal "Z4", assigns(:job).car_type
    assert_equal "W123", assigns(:job).registration_number
    assert_equal "2015-02-02".to_date, assigns(:job).scheduled_collection_time.to_date
    assert_equal "2015-02-02".to_date, assigns(:job).scheduled_delivery_time.to_date
    assert_equal "2015-02-02".to_date, assigns(:job).actual_collection_time.to_date
    assert_equal "2015-02-02".to_date, assigns(:job).actual_delivery_time.to_date
    assert_equal "123", assigns(:job).chassis_number
    assert_equal  100000, assigns(:job).mileage_delivery
    assert_equal  200000, assigns(:job).mileage_collection
    assert_equal "job_notice", assigns(:job).job_notice
    assert_equal "transport_notice", assigns(:job).transport_notice
    assert_equal "transport_notice_extern", assigns(:job).transport_notice_extern
    assert_redirected_to jobs_path
    assert !assigns(:job).shuttle
    assert_equal @job.cost_center_id, assigns(:job).cost_center_id
  end

  test "should create job with co job" do
    sign_in @user
    post :create, job: { cost_center_id: @job.cost_center_id, from_id: routes(:one).from_id, driver_id: drivers(:one).id, shuttle: true, to_id: routes(:one).to_id,
      car_brand: "BMW", car_type: "Z4", registration_number: "W123",
      scheduled_collection_time: "2015-02-02", scheduled_delivery_time: "2015-02-02", chassis_number: "123", mileage_delivery: "100000",
      mileage_collection: "200000", job_notice: "job_notice", transport_notice: "transport_notice", transport_notice_extern: "transport_notice_extern"},
      co_jobs: ",#{jobs(:three).id}, #{jobs(:not_in_shuttle).id}"
    job = Job.find(assigns(:job).id)
    assert_equal jobs(:three), job.co_jobs.first
    assert_equal jobs(:not_in_shuttle), job.co_jobs.last
    assert_equal 2, job.co_jobs.length
    assert_equal 2, job.breakpoints.length
    assert_equal jobs(:three).from, job.breakpoints.first.address
  end

  test "should create job with co job allready in shuttle" do
    sign_in @user
    post :create, job: { cost_center_id: @job.cost_center_id, from_id: routes(:one).from_id, driver_id: drivers(:one).id, shuttle: true, to_id: routes(:one).to_id,
      car_brand: "BMW", car_type: "Z4", registration_number: "W123",
      scheduled_collection_time: "2015-02-02", scheduled_delivery_time: "2015-02-02", chassis_number: "123", mileage_delivery: "100000",
      mileage_collection: "200000", job_notice: "job_notice", transport_notice: "transport_notice", transport_notice_extern: "transport_notice_extern"},
      co_jobs: ",#{jobs(:three).id}, #{jobs(:two).id}"
    assert_redirected_to new_job_path
  end

  test "should not create job with himself in co job" do
    sign_in @user
    post :create, job: { cost_center_id: @job.cost_center_id, from_id: routes(:one).from_id, driver_id: drivers(:one).id, shuttle: true, to_id: routes(:one).to_id,
      car_brand: "BMW", car_type: "Z4", registration_number: "W123",
      scheduled_collection_time: "2015-02-02", scheduled_delivery_time: "2015-02-02", chassis_number: "123", mileage_delivery: "100000",
      mileage_collection: "200000", job_notice: "job_notice", transport_notice: "transport_notice", transport_notice_extern: "transport_notice_extern"},
      co_jobs: ",#{jobs(:one).id}, #{jobs(:two).id}"
      assert_redirected_to new_job_path
  end

  test "should not create job with co jobs with same driver" do
    sign_in @user
    post :create, job: { cost_center_id: @job.cost_center_id, from_id: routes(:one).from_id, driver_id: drivers(:one).id, shuttle: true, to_id: routes(:one).to_id,
      car_brand: "BMW", car_type: "Z4", registration_number: "W123",
      scheduled_collection_time: "2015-02-02", scheduled_delivery_time: "2015-02-02", chassis_number: "123", mileage_delivery: "100000",
      mileage_collection: "200000", job_notice: "job_notice", transport_notice: "transport_notice", transport_notice_extern: "transport_notice_extern"},
      co_jobs: ",#{jobs(:one).id}, #{jobs(:two).id}"
      assert_redirected_to new_job_path
  end

  test "should show job" do
    sign_in @user
    get :show, id: @job
    assert_response :success
  end

  test "should show shuttlejob" do
    sign_in @user
    get :show, id: jobs(:shuttle)
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @job
    assert_response :success
  end

  test "should get editshuttle" do
    sign_in @user
    get :edit, id: jobs(:shuttle)
    assert_response :success
  end

  test "should reorder positions" do
    sign_in @user
    date = Date.current
    breakpoints_beginn = jobs( :shuttle ).breakpoints.order(:position)
    patch :update, id: jobs( :shuttle ), subaction: "update", job: { "breakpoints_attributes" => { "0" => { id: breakpoints_beginn.last.id, position: 0, mileage: 10 }, "1" => { id: breakpoints_beginn.first.id, position: 1, mileage: 100 } } }
    assert_redirected_to jobs_path
    jobs( :shuttle ).reload
    breakpoints_end = jobs(:shuttle).breakpoints.order(:position)
    assert_equal breakpoints_end.first.id, breakpoints_beginn.last.id
    assert_equal breakpoints_end.last.id, breakpoints_beginn.first.id
    assert_equal 10, breakpoints_end.first.mileage
    assert_equal 100, breakpoints_end.last.mileage
  end

  test "should update job" do
    sign_in @user
    date = Date.current
    patch :update, id: @job, subaction: "update", job: { actual_collection_time: date, actual_delivery_time: date, cost_center_id: @job.cost_center_id, created_by_id: @job.created_by_id, driver_id: @job.driver_id, status: @job.status, from_id: @job.from_id, route_id: @job.route_id, shuttle: @job.shuttle, to_id: @job.to_id }
    assert_redirected_to jobs_path
    assert_equal date, assigns(:job).actual_collection_time.to_date
    assert_equal date, assigns(:job).actual_delivery_time.to_date
  end

  test "should remove co_jobs on update" do
    sign_in @user
    assert_not jobs(:shuttle).co_drivers.empty?
    patch :update, id: jobs(:shuttle), subaction: "update", job: { shuttle: "0" }
    assert_redirected_to jobs_path
    jobs(:shuttle).reload
    assert jobs(:shuttle).co_drivers.empty?
  end

  test "should update job and set to current" do
    sign_in @user
    date = Date.current
    patch :update, id: @job, subaction: "update_and_pay", job: { actual_collection_time: date, actual_delivery_time: date, cost_center_id: @job.cost_center_id, created_by_id: @job.created_by_id, driver_id: @job.driver_id, status: @job.status, from_id: @job.from_id, route_id: @job.route_id, shuttle: @job.shuttle, to_id: @job.to_id }
    assert_redirected_to jobs_path
    assert @job.reload
    assert @job.is_finished?
    assert_equal date, assigns(:job).actual_collection_time.to_date
    assert_equal date, assigns(:job).actual_delivery_time.to_date
  end

  test "should update job and not set to current" do
    sign_in @user
    date = Date.current
    @request.env['HTTP_REFERER'] = 'http://localhost:3000/jobs/edit'
    patch :update, id: @job, subaction: "update_and_pay", job: { actual_collection_time: date, actual_delivery_time: nil, cost_center_id: @job.cost_center_id, created_by_id: @job.created_by_id, driver_id: @job.driver_id, status: @job.status, from_id: @job.from_id, route_id: @job.route_id, shuttle: @job.shuttle, to_id: @job.to_id }
    assert_redirected_to 'http://localhost:3000/jobs/edit'
    assert @job.reload
    assert @job.is_open?
    assert_equal date, assigns(:job).actual_collection_time
    assert_equal nil, assigns(:job).actual_delivery_time
  end

  test "should destroy job" do
    sign_in @user
    assert_difference('Job.get_active.count', -1) do
      delete :destroy, id: @job
    end

    assert_redirected_to jobs_path
  end

  test "should not destroy job" do
    sign_in @user
    assert_difference('Job.get_active.count', 0) do
      delete :destroy, id: jobs(:payed)
    end

    assert_redirected_to jobs(:payed)
  end

  test "set_to_current_bill" do
    sign_in @user
    post :add_to_current_bill, id: jobs(:one)
    jobs(:one).reload
    assert jobs(:one).is_finished?
    assert_equal Bill.get_current, jobs(:one).bill
    assert_redirected_to jobs_path
  end

  test "should_not_set_to_current_bill_without_dates" do
    sign_in @user
    post :add_to_current_bill, id: jobs(:one_no_date)
    jobs(:one_no_date).reload
    assert_not jobs(:one_no_date).is_finished?
    assert_redirected_to jobs_path
  end

  test "should_not_set_to_current_bill_with_wrong_dates" do
    sign_in @user
    jobs(:one).actual_delivery_time = 1.day.ago.to_time
    jobs(:one).save
    post :add_to_current_bill, id: jobs(:one)
    jobs(:one_no_date).reload
    assert_not jobs(:one_no_date).is_finished?
    assert_redirected_to jobs_path
  end

  test "should_not_set_to_current_bill_if_breakpoints_not_correct" do
    sign_in @user
    bp = jobs(:shuttle).breakpoints.first
    bp.mileage = nil
    bp.save
    post :add_to_current_bill, id: jobs(:shuttle)
    jobs(:shuttle).reload
    assert_not jobs(:shuttle).is_finished?
    assert_redirected_to jobs_path

    bp.mileage = 1000
    bp.save
    post :add_to_current_bill, id: jobs(:shuttle)
    jobs(:shuttle).reload
    assert_not jobs(:shuttle).is_finished?
    assert_redirected_to jobs_path

    bp.mileage = 150
    bp.save
    post :add_to_current_bill, id: jobs(:shuttle)
    jobs(:shuttle).reload
    assert jobs(:shuttle).is_finished?
    assert_equal Bill.get_current, jobs(:shuttle).bill
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
    post :add_co_driver, id: jobs(:empty_shuttle), co_job_id: jobs( :three ).id
    jobs(:empty_shuttle).reload
    assert_equal 1, jobs(:empty_shuttle).co_drivers.length
  end

  test "add_co_driver_ajax" do
    sign_in @user
    assert_equal 0, jobs(:empty_shuttle).co_drivers.length
    xhr :post, :add_co_driver, id: jobs(:empty_shuttle), co_job_id: jobs( :three ).id
    assert_response :success
    assert_select_jquery :html, '#sidepanel-inner' do
      assert_select '#shuttle-summary tbody > tr', 1
      assert_select '#breakpoints ol', 1
    end
    jobs(:empty_shuttle).reload
    assert_equal 1, jobs(:empty_shuttle).co_drivers.length
  end

  test "show_all_edit_ajax" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "1"=>{"data"=>"1", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "2"=>{"data"=>"2", "name"=>"", "searchable"=>"true", "orderable"=>"true",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0", "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "form_type"=>"edit",
                "main_job_id"=>jobs(:empty_shuttle).id.to_s}
    sign_in @user
    xhr :get, :show_all, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 5, body["recordsFiltered"]
  end

  test "show_all_create_ajax" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "1"=>{"data"=>"1", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "2"=>{"data"=>"2", "name"=>"", "searchable"=>"true", "orderable"=>"true",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0", "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "form_type"=>"create",
                "main_job_id"=>""}
    sign_in @user
    xhr :get, :show_all, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 6, body["recordsFiltered"]
  end

  test "show_all_create_ajax_search1" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "1"=>{"data"=>"1", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "2"=>{"data"=>"2", "name"=>"", "searchable"=>"true", "orderable"=>"true",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0", "length"=>"10",
                "search"=>{"value"=>"tester", "regex"=>"false"},
                "form_type"=>"create",
                "main_job_id"=>""}
    sign_in @user
    xhr :get, :show_all, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 5, body["recordsFiltered"]
  end

  test "show_all_create_ajax_search2" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "1"=>{"data"=>"1", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "2"=>{"data"=>"2", "name"=>"", "searchable"=>"true", "orderable"=>"true",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}},
                  "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                    "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0", "length"=>"10",
                "search"=>{"value"=>"one tester", "regex"=>"false"},
                "form_type"=>"create",
                "main_job_id"=>""}
    sign_in @user
    xhr :get, :show_all, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 3, body["recordsFiltered"]
  end

  test "show_regular_jobs_ajax" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                "search"=>{"value"=>"", "regex"=>"false"}},
                "1"=>{"data"=>"1", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "2"=>{"data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "7"=>{"data"=>"7", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "8"=>{"data"=>"8", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "9"=>{"data"=>"9", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "10"=>{"data"=>"10", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "11"=>{"data"=>"11", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0",
                "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "start_from_date"=>"",
                "end_at_date"=>"",
                "show_open"=>"true",
                "show_finished"=>"false",
                "show_charged"=>"false",
                "show_shuttles"=>"false",
                "show_regular_jobs"=>"true"}
    sign_in @user
    xhr :get, :show_regular_jobs, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 7, body["recordsFiltered"]
  end

  test "show_regular_jobs_ajax_in_date" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                "search"=>{"value"=>"", "regex"=>"false"}},
                "1"=>{"data"=>"1", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "2"=>{"data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "7"=>{"data"=>"7", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "8"=>{"data"=>"8", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "9"=>{"data"=>"9", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "10"=>{"data"=>"10", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "11"=>{"data"=>"11", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0",
                "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "start_from_date"=> I18n.l( Date.today ),
                "end_at_date"=> I18n.l( Date.today ),
                "show_open"=>"true",
                "show_finished"=>"false",
                "show_charged"=>"false",
                "show_shuttles"=>"false",
                "show_regular_jobs"=>"true"}
    sign_in @user
    xhr :get, :show_regular_jobs, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 4, body["recordsFiltered"]
  end

  test "show_regular_jobs_ajax_from_date" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                "search"=>{"value"=>"", "regex"=>"false"}},
                "1"=>{"data"=>"1", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "2"=>{"data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "7"=>{"data"=>"7", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "8"=>{"data"=>"8", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "9"=>{"data"=>"9", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "10"=>{"data"=>"10", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "11"=>{"data"=>"11", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0",
                "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "start_from_date"=> I18n.l( Date.today ),
                "end_at_date"=> nil,
                "show_open"=>"true",
                "show_finished"=>"false",
                "show_charged"=>"false",
                "show_shuttles"=>"false",
                "show_regular_jobs"=>"true"}
    sign_in @user
    xhr :get, :show_regular_jobs, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 5, body["recordsFiltered"]
  end

  test "show_regular_jobs_ajax_end_date" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                "search"=>{"value"=>"", "regex"=>"false"}},
                "1"=>{"data"=>"1", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "2"=>{"data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "7"=>{"data"=>"7", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "8"=>{"data"=>"8", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "9"=>{"data"=>"9", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "10"=>{"data"=>"10", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "11"=>{"data"=>"11", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0",
                "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "start_from_date"=> nil,
                "end_at_date"=> I18n.l( Date.today ),
                "show_open"=>"true",
                "show_finished"=>"false",
                "show_charged"=>"false",
                "show_shuttles"=>"false",
                "show_regular_jobs"=>"true"}
    sign_in @user
    xhr :get, :show_regular_jobs, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 5, body["recordsFiltered"]
  end


  test "show_regular_jobs_ajax_with_shuttles" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                "search"=>{"value"=>"", "regex"=>"false"}},
                "1"=>{"data"=>"1", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "2"=>{"data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "7"=>{"data"=>"7", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "8"=>{"data"=>"8", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "9"=>{"data"=>"9", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "10"=>{"data"=>"10", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "11"=>{"data"=>"11", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0",
                "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "start_from_date"=> "",
                "end_at_date"=> "",
                "show_open"=>"true",
                "show_finished"=>"false",
                "show_charged"=>"false",
                "show_shuttles"=>"true",
                "show_regular_jobs"=>"true"}
    sign_in @user
    xhr :get, :show_regular_jobs, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 9, body["recordsFiltered"]
  end

  test "show_regular_jobs_ajax_just_finished" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                "search"=>{"value"=>"", "regex"=>"false"}},
                "1"=>{"data"=>"1", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "2"=>{"data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "7"=>{"data"=>"7", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "8"=>{"data"=>"8", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "9"=>{"data"=>"9", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "10"=>{"data"=>"10", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "11"=>{"data"=>"11", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0",
                "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "start_from_date"=> "",
                "end_at_date"=> "",
                "show_open"=>"false",
                "show_finished"=>"true",
                "show_charged"=>"false",
                "show_shuttles"=>"false",
                "show_regular_jobs"=>"true"}
    sign_in @user
    xhr :get, :show_regular_jobs, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["recordsFiltered"]
  end

  test "show_regular_jobs_ajax_just_old" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                "search"=>{"value"=>"", "regex"=>"false"}},
                "1"=>{"data"=>"1", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "2"=>{"data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "7"=>{"data"=>"7", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "8"=>{"data"=>"8", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "9"=>{"data"=>"9", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "10"=>{"data"=>"10", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "11"=>{"data"=>"11", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0",
                "length"=>"10",
                "search"=>{"value"=>"", "regex"=>"false"},
                "start_from_date"=> "",
                "end_at_date"=> "",
                "show_open"=>"false",
                "show_finished"=>"false",
                "show_charged"=>"true",
                "show_shuttles"=>"false",
                "show_regular_jobs"=>"true"}
    sign_in @user
    xhr :get, :show_regular_jobs, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 3, body["recordsFiltered"]
  end

  test "show_regular_jobs_ajax_all_in_date_with_licence" do
    params = {"draw"=>"1",
              "columns"=>{"0"=>{"data"=>"0", "name"=>"", "searchable"=>"true", "orderable"=>"false",
                "search"=>{"value"=>"", "regex"=>"false"}},
                "1"=>{"data"=>"1", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "2"=>{"data"=>"2", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "3"=>{"data"=>"3", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "4"=>{"data"=>"4", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "5"=>{"data"=>"5", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "6"=>{"data"=>"6", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "7"=>{"data"=>"7", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "8"=>{"data"=>"8", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "9"=>{"data"=>"9", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "10"=>{"data"=>"10", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}},
                "11"=>{"data"=>"11", "name"=>"", "searchable"=>"false", "orderable"=>"false",
                  "search"=>{"value"=>"", "regex"=>"false"}}},
                "order"=>{"0"=>{"column"=>"1", "dir"=>"desc"}},
                "start"=>"0",
                "length"=>"10",
                "search"=>{"value"=>"w123", "regex"=>"false"},
                "start_from_date"=> I18n.l( Date.today ),
                "end_at_date"=> I18n.l( Date.today ),
                "show_open"=>"true",
                "show_finished"=>"true",
                "show_charged"=>"true",
                "show_shuttles"=>"true",
                "show_regular_jobs"=>"true"}
    sign_in @user
    xhr :get, :show_regular_jobs, params
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["recordsFiltered"]
  end

  test "should_not_add_co_driver_whos_in_shuttle" do
    sign_in @user
    assert_equal 0, jobs(:empty_shuttle).co_drivers.length
    post :add_co_driver, id: jobs(:empty_shuttle), co_job_id: jobs( :one ).id
    jobs(:empty_shuttle).reload
    assert_equal 0, jobs(:empty_shuttle).co_drivers.length
  end

  test "should_not_add_co_driver_twice" do
    sign_in @user
    assert_equal 0, jobs(:empty_shuttle).co_drivers.length
    post :add_co_driver, id: jobs(:empty_shuttle), co_job_id: jobs( :three ).id
    post :add_co_driver, id: jobs(:empty_shuttle), co_job_id: jobs( :same_driver_as_three ).id

    jobs(:empty_shuttle).reload
    assert_equal 1, jobs(:empty_shuttle).co_drivers.length
  end

  test "remove_co_driver" do
    sign_in @user
    assert_equal 2, jobs(:shuttle).co_drivers.length
    post :remove_co_driver, id: jobs(:shuttle), co_job_id: jobs( :two ).id
    shuttle = Job.find(jobs(:shuttle).id)
    assert_equal 1, shuttle.co_drivers.length
    assert_equal [jobs(:one)], shuttle.co_jobs
  end

  test "remove_co_driver_ajax" do
    sign_in @user
    assert_equal 2, jobs(:shuttle).co_drivers.length
    xhr :post, :remove_co_driver, id: jobs(:shuttle), co_job_id: jobs( :two ).id
    assert_response :success
    assert_select_jquery :html, '#sidepanel-inner' do
      assert_select '#shuttle-summary tbody > tr', 1
      assert_select '#breakpoints ol > li', 1
    end

    shuttle = Job.find(jobs(:shuttle).id)
    assert_equal 1, shuttle.co_drivers.length
    assert_equal [jobs(:one)], shuttle.co_jobs
  end
end
