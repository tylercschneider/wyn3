class Calculate::Consumption
  def self.calculate_number_of_days_to_consume(consume_rate:, units_of_item:)
    units_of_item / consume_rate
  end

  def self.consumed_by_date(num_of_days:, start_date: nil)
    base = (start_date || Date.current).to_date
    base + num_of_days
  end
end
