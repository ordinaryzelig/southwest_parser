class Flight < ApplicationRecord

  has_one :fare, :dependent => :destroy

  scope :route, -> (r) { where(r.to_h) }

  attr_accessor :duration_weight_percent
  attr_accessor :points_percent
  attr_accessor :minutes_span
  attr_accessor :earliest_dep_minutes_into_day

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

  def dep_minutes_into_day
    (dep_at - dep_at.at_beginning_of_day).seconds.in_minutes.round
  end

  def arr_minutes_into_day
    (arr_at - dep_at.at_beginning_of_day).seconds.in_minutes.round
  end

  def duration_percent
    (duration / minutes_span.to_f * 100).round
  end

  def offset_duration_percent
    ((dep_minutes_into_day - earliest_dep_minutes_into_day) / minutes_span.to_f * 100).round
  end

end
