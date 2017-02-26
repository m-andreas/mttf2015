require 'test_helper'
class OvertimeTest < ActiveSupport::TestCase
  def test_get_workingdays
    assert_equal 24, Overtime.workdays( "10/02/2017 12:00".to_datetime ).length
  end

  def test_get_times_per_month_good
    overtime = Overtime.get_times_per_month( "10/09/2016 12:00".to_datetime )
    driver_1 = overtime.detect{ |driver| driver[:id] == 1}
    driver_2 = overtime.detect{ |driver| driver[:id] == 2}
    driver_3 = overtime.detect{ |driver| driver[:id] == 3}
    assert_equal overtime.length, 3
    assert_equal true, driver_1[:missing_days]
    assert_equal false, driver_2[:missing_days]
  end

  def test_driver_2
    driver_2 = drivers(:two)
    overtime = Overtime.driver_total_overtime driver_2, "10/09/2016 12:00".to_datetime
    assert_equal 39.5, overtime["total"]
  end

  def test_driver_1
    driver_1 = drivers(:one)
    overtime = Overtime.driver_total_overtime driver_1, "10/09/2016 12:00".to_datetime
    assert_equal 49, overtime["total"]
  end

  def test_driver_3
    driver_3 = drivers(:three)
    overtime = Overtime.driver_total_overtime driver_3, "10/09/2016 12:00".to_datetime
    assert_equal 14.5, overtime["total"]
  end

end
