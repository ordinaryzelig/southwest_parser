class Search

  include ActiveModel::Model

  attr_reader :flights
  attr_accessor :dep
  attr_accessor :arr
  attr_accessor :dep_on
  attr_accessor :currency

  def initialize(atts = {})
    atts.each do |k, v|
      send "#{k}=", v
    end
  end

  def call
    make_request
    parse_flights
    persist
    @flights = find_all
  end

  def to_model
    self
  end

  %i[dep arr].each do |dep_arr|
    define_method "#{dep_arr}=" do |v|
      instance_variable_set :"@#{dep_arr}", v.upcase
    end
  end

  def currency=(c)
    @currency = Currency.new(c)
  end

 private

  def make_request
    request = Request.new(@dep, @arr, @dep_on, @currency)
    request.call
    @response = request.response
  end

  def parse_flights
    json = JSON.load(@response.body)
    #puts JSON.pretty_generate(json)
    @parsed_flights = Search::Parser.parse_all(json)
  end

  def persist
    @persister = SearchPersister.new(@parsed_flights)
    @persister.call
  end

  def find_all
    Flight.find(@persister.flight_ids)
  end

end
