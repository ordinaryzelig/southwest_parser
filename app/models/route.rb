class Route

  class << self

    def from_string(str)
      new *str.split('-')
    end

  end

  attr_accessor :dep
  attr_accessor :arr

  def initialize(dep, arr)
    @dep = dep
    @arr = arr
  end

  def to_h
    {
      :dep => dep,
      :arr => arr,
    }
  end

  def to_s
    "#{dep}-#{arr}"
  end

end
