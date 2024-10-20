class Flight < ApplicationRecord

  has_one :fare, :dependent => :destroy

  scope :route, -> (r) { where(r.to_h) }

  attr_accessor :duration_percent
  attr_accessor :points_percent

  def generate_ident
    self.ident = [
      dep,
      dep_at,
      arr,
      arr_at,
    ].map(&:to_s).join('|')
  end

  def route
    "#{dep}-#{arr}"
  end

  def airports
    [
      dep,
      *layover_airports.split(','),
      arr,
    ]
  end

  def duration_percent_of_day
    (duration.minutes.to_f / 1.day.to_f * 100).round
  end

  def duration_percentage_splits
    [
      (dep_at.seconds_since_midnight.to_f / 1.day.seconds.to_f * 100).round,
      duration_percent_of_day,
    ]
  end

end
