class SearchJsonParser::Segment

  def initialize(json)
    @json = json
  end

  def destination_airport_code
    @json.fetch('destinationAirportCode')
  end

end
