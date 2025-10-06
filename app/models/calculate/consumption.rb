class Calculate::Consumption
  CONSUMPTION_PERIOD = {
    "daily" => 1,
    "weekly" => 7,
    "monthly" => 30,
    "yearly" => 360
  }.freeze

  def self.days_to_consume(consume_rate:, units_of_item:)
    units_of_item / consume_rate
  end

  def self.future_date(num_of_days:, start_date: nil)
    base = (start_date || Date.current).to_date
    base + num_of_days
  end

  def self.rate(consumption_period:, quantity_consumed:)
    quantity_consumed / CONSUMPTION_PERIOD[consumption_period]
  end

  def self.consumed_by_date
    Date.new(2024, 1, 11)
  end
end
