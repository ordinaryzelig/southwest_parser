class SearchJsonParser::Price

  TYPES = {
    'POINTS' => :points,
    'USD'    => :cash,
  }

  def initialize(json)
    @json = json
  end

  def value
    @json.fetch('value')
  end

  def currency
    @json.fetch('currencyCode')
  end

  def type
    TYPES.fetch(currency)
  end

  def to_s
    "#{value} #{currency}"
  end

  TYPES.values.each do |t|
    define_method "#{t}?" do
      type == t
    end
  end

end
