require 'delegate'

# Mulitple Results, all the same except different prices (points/cash).
# Delegate to first result but add methods to get specific price.
class ResultSet < SimpleDelegator

  class << self

    def group(results)
      results
        .group_by(&:ident)
        .values
        .map(&method(:new))
        .sort_by(&:dep_at)
    end

  end

  def initialize(results)
    @results = results
    super results.first
  end

  def prices
    @results.map(&:price)
  end

  def price_in_cash
    prices.detect(&:cash?)
  end

  def price_in_points
    prices.detect(&:points?)
  end

end
