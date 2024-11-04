module SearchesHelper

  def last_searched(route, date)
    CachedSearch.where(:route => route, :date => date).last&.created_on
  end

end
