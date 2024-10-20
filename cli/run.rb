require 'bundler'
Bundler.require

require 'csv'
require 'json'
Dir.glob(__dir__ + '/models/**/*.rb').each(&method(:require))

dir = ARGV.first
results =
  Dir.glob(dir + '/*.json').flat_map do |file|
    json = JSON.parse(File.read(file))
    Result.parse_all(json)
  end

result_sets = ResultSet.group(results)

csv = CSV.generate do |c|
  c << %w[
    dep_at
    arr_at
    duration
    num_stops
    layover_airports
    price_in_points
    price_in_cash
  ]
  result_sets.each do |res|
    c << [
      res.dep_at.strftime('%F %R'),
      res.arr_at.strftime('%F %R'),
      res.duration / 60.0 / 24.0,
      res.num_stops,
      res.layover_airports.join(','),
      res.price_in_points&.value,
      res.price_in_cash&.value,
    ]
  end
end
puts csv
