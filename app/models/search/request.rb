class Search::Request

  attr_reader :response
  attr_reader :dep
  attr_reader :arr
  attr_reader :dep_on
  attr_reader :currency

  def initialize(dep, arr, dep_on, currency)
    @dep      = dep
    @arr      = arr
    @dep_on   = dep_on
    @currency = currency
  end

  def call
    @response = conn.post do |req|
      req.body = body
    end
    raise @response.body unless @response.success?
    log_response
    @response
  end

private

  def log_response
    CachedSearch.save(self)
  end

  URL = 'https://www.southwest.com/api/air-booking/v1/air-booking/page/air/booking/shopping'

  SW_CURRENCIES = {
    :points => 'POINTS',
    :cash   => 'USD',
  }

  def conn
    @conn ||= conn = Faraday.new(
      :url => URL,
      :headers => headers_from_config,
    ) do |f|
      f.response :logger
    end
  end

  def headers_from_config
    eval File.read(Rails.root + 'config/search_headers.rb')
  end

  def body
    {
      :adultPassengersCount     => "1",
      :departureDate            => @dep_on.to_s,
      :departureTimeOfDay       => "ALL_DAY",
      :destinationAirportCode   => @arr,
      :fareType                 => SW_CURRENCIES.fetch(@currency.type),
      :int                      => "LFCBOOKAIR",
      :lapInfantPassengersCount => "0",
      :originationAirportCode   => @dep,
      :passengerType            => "ADULT",
      :promoCode                => "",
      :returnAirportCode        => "",
      :returnDate               => "",
      :returnTimeOfDay          => "ALL_DAY",
      :selectedFlight1          => "",
      :selectedFlight2          => "",
      :tripType                 => "oneway",
      :application              => "air-booking",
      :site                     => "southwest",
    }.to_json
  end

end
