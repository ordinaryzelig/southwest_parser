class Flight < ApplicationRecord

  has_one :fare, :dependent => :destroy

  scope :route, -> (r) { where(r.to_h) }

  attr_accessor :duration_weight_percent
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
    (duration / 1.day.in_minutes.to_f * 100).round
  end

end
