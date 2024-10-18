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

private

  def segments
    @segments ||= @json.fetch('segments').map(&Segment.method(:new))
  end

  class Segment

    def initialize(json)
      @json = json
    end

    def destination_airport_code
      @json.fetch('destinationAirportCode')
    end

  end

  class Fare

    def initialize(json)
      @json = json
    end

    def price
      @json
        .fetch('baseFare')
        .then(&Price.method(:new))
    end

    def available?
      @json.fetch('availabilityStatus') == 'AVAILABLE'
    end

    def unavailable?
      !available?
    end

  end

  class Price

    def initialize(json)
      @json = json
    end

    def value
      @json.fetch('value')
    end

    def currency
      @json.fetch('currencyCode')
    end

    def to_s
      "#{value} #{currency}"
    end

  end

end
