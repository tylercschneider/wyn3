require "test_helper"

class Calculate::ConsumptionTest < ActiveSupport::TestCase
  def test_days_to_consume
    days_to_consume = 5
    assert_equal days_to_consume, Calculate::Consumption.days_to_consume(consume_rate: 2, units_of_item: 10)
  end

  def test_future_date
    future_date = Date.new(2024, 1, 11)
    assert_equal future_date, Calculate::Consumption.future_date(start_date: Date.new(2024, 1, 1), num_of_days: 10)
  end

  def test_future_date_with_no_start_date_specified
    travel_to Time.zone.parse("2025-10-02 09:00:00") do
      future_date = Date.new(2025, 10, 12)
      assert_equal future_date, Calculate::Consumption.future_date(num_of_days: 10)
    end
  end

  def test_consumption_rate
    consumption_rate = 20
    assert_equal consumption_rate, Calculate::Consumption.rate(
      consumption_period: "per_day",
      quantity_consumed: 20
    )
  end

  def test_consumption_rate_handles_weekly
    consumption_rate = 4

    assert_equal consumption_rate, Calculate::Consumption.rate(
      consumption_period: "per_week",
      quantity_consumed: 28
    )
  end

  def test_consumption_rate_handles_monthly
    consumption_rate = 1

    assert_equal consumption_rate, Calculate::Consumption.rate(
      consumption_period: "per_month",
      quantity_consumed: 30
    )
  end

  def test_consumption_rate_handles_yearly
    consumption_rate = 1

    assert_equal consumption_rate, Calculate::Consumption.rate(
      consumption_period: "per_year",
      quantity_consumed: 360
    )
  end

  def test_consumed_by_date
    consumed_by_date = Date.new(2024, 1, 30)
    assert_equal consumed_by_date, Calculate::Consumption.consumed_by_date(
      start_date: Date.new(2024, 1, 10),
      units_of_item: 80,
      quantity_consumed: 4,
      consumption_period: "per_day"
    )
  end
end
