class Price

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

  def price_type
    TYPES.fetch(currency)
  end

  def to_s
    "#{value} #{currency}"
  end

  TYPES.values.each do |type|
    define_method "#{type}?" do
      price_type == type
    end
  end

end
