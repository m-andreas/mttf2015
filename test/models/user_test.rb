require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "test_is_intern" do
    assert users(:intern).is_intern?
  end

  test "fail_is_intern" do
    assert_not users(:extern).is_intern?
  end
end
