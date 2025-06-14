class Search::Parser::Flight

  attr_accessor :flight_id

  def initialize(json)
    @json = json
  end

  def dep
    @dep ||= @json.fetch('originationAirportCode')
  end

  def arr
    @arr ||= @json.fetch('destinationAirportCode')
  end

  def dep_at
    @dep_ap ||= DateTime.parse(@json.fetch('departureDateTime'))
  end

  def arr_at
    @arr_ap ||= DateTime.parse(@json.fetch('arrivalDateTime'))
  end

  def price
    @price ||= fare.price
  end

  def unavailable?
    fare.unavailable?
  end

  def num_stops
    segments.size - 1 + segments.sum(&:num_stops)
  end

  def layover_airports
    @layover_airports ||=
      if num_stops > 0
        segments[0..-2].map(&:destination_airport_code)
      else
        []
      end
  end

  def duration
    @duration ||= Integer(@json.fetch('totalDuration'))
  end

  def fare
    @fare ||= Search::Parser::Fare.parse_from_flight(@json)
  end

  def ident
    [
      dep_at,
      arr_at,
    ].map(&:to_s).join('|')
  end

  def validate!
    dep_at
    arr_at
    duration
    num_stops
    layover_airports
    price
  rescue
    puts ident
    raise
  end

  def route
    "#{dep}-#{arr}"
  end

private

  def segments
    @segments ||= @json.fetch('segments').map(&Search::Parser::Segment.method(:new))
  end

end
