class SearchesController < ApplicationController

  def new
    @search = Search.new(
      :dep      => 'okc',
      :arr      => 'lga',
      :dep_on   => Date.new(2024, 10, 24),
      :currency => :points,
    )
  end

  def create
    search = Search.new(search_params)
    search.call
    redirect_to search_path(search.flights.first.route)
  end

  def show
    @route = Route.from_string(params[:id])
    @flights =
      Flight
        .route(@route)
        .includes(:fare)
    calculations
  end

private

  def search_params
    params
      .require(:search)
      .permit(
        :dep,
        :arr,
        :dep_on,
        :currency,
      )
  end

  def calculations
    durations = @flights.map(&:duration)
    min_duration, max_duration = durations.min, durations.max
    hundred = max_duration - min_duration
    @flights.each do |flight|
      flight.duration_percent = 100 - ((flight.duration - min_duration) / hundred.to_f * 100).round
    end

    invert = true
    all = @flights.filter_map { |fl| fl.fare&.points }
    min, max = all.min, all.max
    hundred = max - min
    @flights.each do |flight|
      if flight.fare&.points
        flight.points_percent = ((flight.fare.points - min) / hundred.to_f * 100).round
        flight.points_percent = 100 - flight.points_percent if invert
      end
    end
  end

end
