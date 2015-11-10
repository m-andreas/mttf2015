require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should show user" do
    sign_in @user
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    sign_in @user
    patch :update, id: @user, user: { user_name: "test"  }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    sign_in @user
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
