class Result

  class << self

    def parse_all(json)
      json
        .fetch('data')
        .fetch('searchResults')
        .fetch('airProducts')
        .first
        .fetch('details')
        .map(&method(:new))
    end

  end

  def initialize(json)
    @json = json
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
    flight_numbers.size - 1
  end

  def layover_airports
    @layover_airports ||=
      if num_stops > 0
        segments[0..-2].map(&:destination_airport_code)
      else
        []
      end
  end

  def flight_numbers
    @flight_numbers ||= @json.fetch('flightNumbers')
  end

  def duration
    @duration ||= Integer(@json.fetch('totalDuration'))
  end

  def fare
    @fare ||= Fare.new(
      @json
        .fetch('fareProducts')
        .fetch('ADULT')
        .then { |n| n['WGA'] || n['WGARED'] }
        .fetch('fare')
      )
  end

  def ident
    [
      dep_at,
      arr_at,
    ].map(&:to_s).join('|')
  end

private

  def segments
    @segments ||= @json.fetch('segments').map(&Segment.method(:new))
  end

end
