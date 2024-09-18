require 'bundler'
Bundler.require

require 'csv'
Dir.glob(__dir__ + '/models/**/*.rb').each(&method(:require))

results =
  Dir.glob(__dir__ + '/html/*.html').flat_map do |file|
    html = File.read(file)
    Result.parse_html(html)
  end

csv = CSV.generate do |c|
  c << %w[
    date
    dep_at
    arr_at
    duration
    num_stops
    layover_airports
    price
  ]
  results.each do |res|
    c << [
      res.date_str,
      res.dep_at,
      res.arr_at,
      res.duration,
      res.num_stops,
      res.layover_airports,
      res.price,
    ]
  end
end
puts csv
