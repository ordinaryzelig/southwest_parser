require 'bundler'
Bundler.require

class Result

  def initialize(node)
    @node = node
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
        points = fare.css('.currency_points .swa-g-screen-reader-only').text
        Integer(points.gsub(/\D/, ''))
      end
  end

  def num_stops
    @num_stops ||= stops.css('.flight-stops-badge').first.text
  end

  def layover_airports
    @layover_airports ||= stops.css('.select-detail--change-planes').text[/(?<=Change planes ).*/]
  end

  def flight_numbers
    @flight_numbers ||= @node.css('.flight-numbers--flight-number .actionable--text').text
  end

  def duration
    @duration ||= @node.css('.select-detail--flight-duration').text
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

html = File.read(__dir__ + '/html/3-18.html')
doc = Nokogiri.HTML(html, &:noblanks)
results = doc.css('.search-results--container').first
rows = results.css('li.air-booking-select-detail')
puts rows.size
rows.each do |row|
  res = Result.new(row)
  puts res.dep_at
  puts res.arr_at

  puts res.price

  puts res.num_stops
  puts res.layover_airports

  puts res.duration

  puts res.flight_numbers

  puts
end
