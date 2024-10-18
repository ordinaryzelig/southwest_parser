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
