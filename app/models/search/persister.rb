class Search::Persister

  attr_reader :flight_ids

  def initialize(parsed_flights, search)
    @parsed_flights = parsed_flights
    @search         = search
    @flight_ids     = []
  end

  def call
    Flight.transaction do
      upsert_flights
      expire_flights
      upsert_fares
    end
  end

private

  def upsert_flights
    @flight_ids = @parsed_flights.map do |parsed_flight|
      flight_atts = {
        :dep              => parsed_flight.dep,
        :arr              => parsed_flight.arr,
        :dep_at           => parsed_flight.dep_at,
        :arr_at           => parsed_flight.arr_at,
        :duration         => parsed_flight.duration,
        :stops            => parsed_flight.num_stops,
        :layover_airports => parsed_flight.layover_airports.join(',').presence
      }
      @flights_upsert_res =
        Flight.upsert(
          flight_atts,
          :returning => :id,
          :unique_by => %i[dep arr dep_at arr_at],
        )
      flight_id = @flights_upsert_res.first.fetch('id')
      parsed_flight.flight_id = flight_id
    end
  end

  # Can't use `updated_at`, because if nothing changes about the flight, then
  # updated_at is untouched.
  def expire_flights
    Flight
      .route(@search.route)
      .dep_date(@search.dep_on)
      .where.not(:id => @parsed_flights.filter_map(&:flight_id))
      .touch_all(:expired_at)
  end

  def upsert_fares
    @parsed_flights.each do |parsed_flight|
      parsed_fare = parsed_flight.fare
      next unless parsed_fare
      fare_atts = {
        :flight_id => parsed_flight.flight_id,
        :available => parsed_fare.available?,
      }
      if parsed_fare.available?
        price = parsed_fare.price
        fare_atts[price.type] =
          case price.type
          when :cash
            Integer(BigDecimal(price.value) * 100)
          when :points
            price.value
          else
            raise "Unknown price type: #{price.type}"
          end
      else
        # Assuming that if one isn't available, neither is the other.
        fare_atts[:points] = nil
        fare_atts[:cash]   = nil
      end
      res = Fare.upsert(
        fare_atts,
        :unique_by => :flight_id,
      )
    end
  end

end
