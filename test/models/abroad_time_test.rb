require 'test_helper'

class AbroadTimeTest < ActiveSupport::TestCase
  def test_get_times_per_month
    AbroadTime.get_times_per_month Date.today
  end

  def test_calc_nex_day
    assert_equal 3, AbroadTime.calc( "23:00".to_time, "2:00".to_time )
  end

  def test_calc_to_zero
    assert_equal 2, AbroadTime.calc( "22:00".to_time, "00:00".to_time )
  end

  def test_calc_from_zero
    assert_equal 4, AbroadTime.calc( "00:00".to_time, "04:00".to_time )
  end

  def test_if_times_are_sent
    returned_array = AbroadTime.get_times_per_month Date.today
    assert_equal 5.0, returned_array.first[:time]
    assert_equal 3.0, returned_array.second[:time]
    assert_equal 0, returned_array.last[:time]
  end

end
