class Result

  class << self

    def parse_html(html)
      doc = Nokogiri.HTML(html, &:noblanks)
      date = doc.css('.calendar-strip--date').first.text
      results = doc.css('.search-results--container').first
      rows = results.css('li.air-booking-select-detail')
      rows.filter_map do |row|
        res = new(row, date)
        res unless res.unavailable?
      end
    end

  end

  attr_reader :date_str

  def initialize(node, date_str)
    @node     = node
    @date_str = date_str
  end

  def dep_at
    @dep_ap ||= times.first
  end

  def arr_at
    @arr_at || times.last
  end

  def price
    @price ||=
      begin
        fare = @node.css('.fare-button').detect { |f| f['data-test'] == 'fare-button--wanna-get-away'}
        points = fare.css('.currency_points .swa-g-screen-reader-only')
        if points.size > 0
          str = points.text
          Integer(str.gsub(/\D/, ''))
        end
      end
  end

  def unavailable?
    price.nil?
  end

  def num_stops
    @num_stops ||= stops.css('.flight-stops-badge').first.text.to_i
  end

  def layover_airports
    @layover_airports ||= stops.css('.select-detail--change-planes').text[/(?<=Change planes ).*/]
  end

  def flight_numbers
    @flight_numbers ||= @node.css('.flight-numbers--flight-number .actionable--text').text
  end

  def duration
    @duration ||=
      begin
        str = @node.css('.select-detail--flight-duration').text
        hours, mins = str.split.map(&:to_i)
        (hours * 60) + mins
      end
  end

private

  def times
    @times ||= @node.css('.air-operations-time-status').map do |time|
      time.text[/\d+:\d+(AM|PM)/]
    end
  end

  def stops
    @stops ||= @node.css('.select-detail--number-of-stops')
  end

end
