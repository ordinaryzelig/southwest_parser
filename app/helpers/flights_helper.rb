module FlightsHelper

  def duration_in_words(minutes)
    dur = ActiveSupport::Duration.build(minutes.minutes).parts
    "#{dur.fetch(:hours)}h #{dur.fetch(:minutes, 0)}m"
  end

end
