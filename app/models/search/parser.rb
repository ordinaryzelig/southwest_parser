class Search::Parser

  class << self

    def parse_all(json)
      json
        .fetch('data')
        .fetch('searchResults')
        .fetch('airProducts')
        .first
        .fetch('details')
        .map(&Search::Parser::Flight.method(:new))
    end

    def parse_response(response)
      parse_json_string(response.body)
    end

    def parse_json_string(str)
      json = JSON.parse(str)
      parse_all json
    end

    def parse_file(path)
      parse_json_string(File.read(path))
    end

  end

end
