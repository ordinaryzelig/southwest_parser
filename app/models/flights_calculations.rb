class FlightsCalculations

  def initialize(flights)
    @flights = flights
  end

  def call
    @flights.each do |f|
      f.minutes_span = minutes_span
      f.earliest_dep_minutes_into_day = dep_min
    end
    calculate(:duration_weight_percent) { |f| f.duration }
    calculate(:points_percent)          { |f| f.fare&.points }
  end

  %i[dep arr].each do |dep_arr|
    %i[min max].each do |min_max|
      meth = "#{dep_arr}_#{min_max}"
      define_method meth do
        ivar = "@#{meth}"
        instance_variable_get ivar or
          instance_variable_set ivar, @flights.map(&:"#{dep_arr}_minutes_into_day").send(min_max) / 60
      end
    end
  end

  %i[min max].each do |min_max|
    define_method "duration_#{min_max}" do
      (@flights.map(&:duration).send(min_max) / 60.to_f).ceil
    end
  end

  %i[min max].each do |min_max|
    define_method "stops_#{min_max}" do
      @flights.map(&:stops).send(min_max)
    end
  end

  %i[min max].each do |min_max|
    define_method "kpoints_#{min_max}" do
      (@flights.filter_map { |f| f.fare&.points }.send(min_max) / 1000.to_f).ceil
    end
  end

  def duration_average
    flights = @flights.select(&:duration)
    flights.map(&:duration).sum / flights.size / 60
  end

  def points_average
    flights = @flights.select { |f| f.fare&.points }
    (flights.map { |f| f.fare.points }.sum / flights.size).round
  end

  def layovers
    @layovers ||= @flights.flat_map(&:layover_airports).uniq
  end

private

  def calculate(percent_attr, &block)
    all = @flights.filter_map(&block)
    min, max = all.min, all.max
    hundred = [max - min, 1].max
    @flights.each do |flight|
      flight_val = block.call(flight)
      if flight_val
        percent = ((flight_val - min) / hundred.to_f * 100).round
        flight.send("#{percent_attr}=", percent)
      end
    end
  end

  def latest_arr_minutes_into_day
    @latest_arr_at ||= @flights.map(&:arr_minutes_into_day).max
  end

  # Minutes between earliest dep_at and latest arr_at.
  # Represents largest window so that any flight would fully fit.
  def minutes_span
    @minutes_span ||= latest_arr_minutes_into_day - dep_min
  end

end
