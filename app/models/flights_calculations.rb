class FlightsCalculations

  def initialize(flights)
    @flights = flights
  end

  def call
    @flights.each do |f|
      f.minutes_span = minutes_span
      f.earliest_dep_minutes_into_day = earliest_dep_minutes_into_day
    end
    calculate(:duration_weight_percent) { |f| f.duration }
    calculate(:points_percent)          { |f| f.fare&.points }
  end

private

  def calculate(percent_attr, &block)
    all = @flights.filter_map(&block)
    min, max = all.min, all.max
    hundred = max - min
    @flights.each do |flight|
      flight_val = block.call(flight)
      if flight_val
        percent = ((flight_val - min) / hundred.to_f * 100).round
        flight.send("#{percent_attr}=", percent)
      end
    end
  end

  def earliest_dep_minutes_into_day
    @earliest_dep_at ||= @flights.map(&:dep_minutes_into_day).min
  end

  def latest_arr_minutes_into_day
    @latest_arr_at ||= @flights.map(&:arr_minutes_into_day).max
  end

  # Minutes between earliest dep_at and latest arr_at.
  # Represents largest window so that any flight would fully fit.
  def minutes_span
    @minutes_span ||= latest_arr_minutes_into_day - earliest_dep_minutes_into_day
  end

end
