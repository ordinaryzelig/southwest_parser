class Fare

  def initialize(json)
    @json = json
  end

  def price
    @json
      .fetch('baseFare')
      .then(&Price.method(:new))
  end

  def available?
    @json.fetch('availabilityStatus') == 'AVAILABLE'
  end

  def unavailable?
    !available?
  end

end
