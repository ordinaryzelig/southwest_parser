class Search::Parser::Segment

  def initialize(json)
    @json = json
  end

  def destination_airport_code
    @json.fetch('destinationAirportCode')
  end

  def num_stops
    @json.fetch('numberOfStops')
  end

end
