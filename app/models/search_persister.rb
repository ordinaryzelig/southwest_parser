class SearchPersister

  attr_reader :flight_ids

  def initialize(parsed_flights)
    @parsed_flights = parsed_flights
    @flight_ids = []
  end

  def call
    Flight.transaction do
      upsert_flights
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
        :layover_airports => parsed_flight.layover_airports.join(',')
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

  def upsert_fares
    @parsed_flights.each do |parsed_flight|
      parsed_fare = parsed_flight.fare
      fare_atts = {
        :flight_id => parsed_flight.flight_id,
        :available => parsed_fare.available?,
      }
      price = parsed_fare.price
      next unless price
      fare_atts[price.type] =
        if parsed_fare.available?
          if price.cash?
            Integer(BigDecimal(price.value) * 100)
          else
            price.value
          end
        else
          nil
        end
      res = Fare.upsert(
        fare_atts,
        :unique_by => :flight_id,
      )
    end
  end

end
