require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "get correct addresses" do
    assert_equal addresses(:one), jobs(:one).from
    assert_equal addresses(:two), jobs(:one).to
  end
end
