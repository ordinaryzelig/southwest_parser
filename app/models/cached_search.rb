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
    Search::Persister.new(parsed_flights, self).call
  end

  def route
    @route ||= Route.from_string(filename_parts[1])
  end

  def dep_on
    @dep_on ||= filename_parts[2]
  end

  def created_on
    @created_at ||= filename_parts[0].to_date
  end

private

  def filename_parts
    filename.to_s.split('|')
  end

end
