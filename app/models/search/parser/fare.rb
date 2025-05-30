class Search::Parser::Fare

  class << self

    FARE_TYPE_IDENTS = %w[
      WGA
      WGARED
      PLURED
    ]

    def parse_from_flight(json)
      return nil unless json.key?('fareProducts')
      fare_json =
        json
          .fetch('fareProducts')
          .fetch('ADULT')
          .then do |n|
            keys = n.keys
            key = (FARE_TYPE_IDENTS & keys).first
            raise "No fare found from #{keys.inspect}" unless key
            n.fetch(key)
          end
      new(fare_json)
    end

  end

  def initialize(json)
    @json = json
  end

  def price
    return nil unless available?
    @json
      .fetch('fare')
      .fetch('totalFare')
      .then(&Search::Parser::Price.method(:new))
  rescue
    puts @json
    raise
  end

  def available?
    @json.fetch('availabilityStatus') == 'AVAILABLE'
  end

  def unavailable?
    !available?
  end

end
