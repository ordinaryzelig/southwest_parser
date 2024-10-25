class Currency

  TYPES = [
    :points,
    :cash,
  ]

  attr_reader :type

  class << self

    def all
      TYPES.map(&method(:new))
    end

  end

  def initialize(type)
    @type = type.to_sym
    raise unless TYPES.include?(@type)
  end

  def inspect
    @type
  end

end
