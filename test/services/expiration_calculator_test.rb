require 'test_helper'

class ExpirationCalculatorTest < ActiveSupport::TestCase

  def test_calculate_number_of_days_to_consume  
    number_of_days_to_consume = 5
    assert_equal number_of_days_to_consume, ExpirationCalculator.calculate_number_of_days_to_consume(consume_rate: 2, units_of_item: 10)
  end

  def test_must_expire_after_date
    expire_after_date = Date.new(2024,1,11)
    assert_equal expire_after_date, ExpirationCalculator.must_expire_after_date(from: Date.new(2024,1,1), num_of_days: 10)
  end

  def test_must_expire_after_date_no_from_specified
    travel_to Time.zone.parse("2025-10-02 09:00:00") do
      expire_after_date = Date.new(2025, 10, 12)
      assert_equal expire_after_date, ExpirationCalculator.must_expire_after_date(num_of_days: 10)
    end
  end
end
