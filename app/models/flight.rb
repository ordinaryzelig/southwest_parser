class Flight < ApplicationRecord

  has_one :fare

  scope :route, -> (r) { where(r.to_h) }

  def generate_ident
    self.ident = [
      dep,
      dep_at,
      arr,
      arr_at,
    ].map(&:to_s).join('|')
  end

end
