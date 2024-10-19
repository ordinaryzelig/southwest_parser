class Fare

  def initialize(json)
    @json = json
  end

  def price
    return nil unless available?
    @json
      .fetch('fare')
      .fetch('baseFare')
      .then(&Price.method(:new))
  rescue
    puts @json
    raise
  end

  def available?
    @json.fetch('availabilityStatus') == 'AVAILABLE'
  end

  def unavailable?
    !available?
  end

end
