require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "get correct addresses" do
    assert_equal addresses(:one), jobs(:one).from
    assert_equal addresses(:two), jobs(:one).to
  end

  test "is_shuttle" do
    assert jobs(:shuttle).is_shuttle?
    assert_not jobs(:one).is_shuttle?
  end

  test "must_have_driver_id" do
    job = Job.new
    assert_not job.valid?
    assert_equal [:status], job.errors.keys
  end

  test "add_stop" do
  end

  test "remove_shuttles" do
    assert_equal 2, jobs(:shuttle).stops.length
    jobs(:shuttle).remove_shuttles
    jobs(:shuttle).reload
    assert jobs(:shuttle).stops.empty?
  end
end
