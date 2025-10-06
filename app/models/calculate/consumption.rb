class Calculate::Consumption
  def self.calculate_number_of_days_to_consume(consume_rate:, units_of_item:)
    units_of_item / consume_rate
  end

  def self.must_expire_after_date(num_of_days:, from: nil)
    base = (from || Date.current).to_date
    base + num_of_days
  end
end
