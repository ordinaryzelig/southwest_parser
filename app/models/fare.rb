class Fare < ApplicationRecord
  belongs_to :flight

  def kpoints
    (points / 1000.to_f).round
  end

  # Average is about 68 points per dollar.
  def point_value
    return unless points && cash
    (points / cash.to_f * 100).round
  end
end
