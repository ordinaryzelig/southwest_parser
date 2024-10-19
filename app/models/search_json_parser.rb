class SearchJsonParser

  class << self

    def parse_all(json)
      json
        .fetch('data')
        .fetch('searchResults')
        .fetch('airProducts')
        .first
        .fetch('details')
        .map(&SearchJsonParser::Flight.method(:new))
    end

  end

end
