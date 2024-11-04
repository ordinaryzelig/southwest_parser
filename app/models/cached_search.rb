class CachedSearch

  class << self

    def where(route:, date:)
      Dir.glob(Rails.root + "log/searches/*|#{route}|#{date.presence || '*'}|*").map(&method(:new))
    end

  end

  attr_reader :path

  def initialize(path)
    @path = Pathname(path)
  end

  def filename
    @path.basename
  end

  def load
    json = JSON.load(@path.read)
    parsed_flights = Search::Parser.parse_all(json)
    Search::Persister.new(parsed_flights).call
  end

  def route
    filename.to_s.split('|')[1]
  end

end
