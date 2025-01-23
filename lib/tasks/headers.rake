task :headers_from_curl do
  input = STDIN.read
  options = input.scan(/(?<=\s{3}-H\s').+?(?=')/)
  headers = options.each_with_object({}) do |option, hash|
    name, value = option.split(': ')
    hash[name] = value
  end
  File.open(Rails.root + 'config/search_headers.rb', 'w+') { |f| f.write headers.ai(:plain => true) }
end
