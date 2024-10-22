class Airport

  TIMEZONES = {
    'HOU' => 'Central Time (US & Canada)',
    'LGA' => 'Eastern Time (US & Canada)',
    'OKC' => 'Central Time (US & Canada)',
  }

  def initialize(code)
    @code = code
  end

  def time_zone
    ActiveSupport::TimeZone[TIMEZONES.fetch(@code)] || raise("TIMEZONE not found.")
  end

end
