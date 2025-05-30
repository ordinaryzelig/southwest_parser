class CachedSearch

  class << self

    FILES_PATH = Rails.root + 'log/searches'

    def where(route:, date:)
      Dir.glob(FILES_PATH + "/*|#{route}|#{date.presence || '*'}|*").map(&method(:new))
    end

    def save(search_request)
      json = JSON.pretty_generate(JSON.parse(search_request.response.body))
      path = FILES_PATH + "#{Time.now}|#{search_request.dep}-#{search_request.arr}|#{search_request.dep_on}|#{search_request.currency}.json"
      File.open(path, 'w') { |f| f.write json }
    end

    def last
      last_file = Dir.glob(FILES_PATH + '*').entries.last
      new(last_file) if last_file
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

  def currency
    @currency ||= filename_parts[3].to_sym
  end

private

  def filename_parts
    filename.to_s.split(/[|\.]/)
  end

end
