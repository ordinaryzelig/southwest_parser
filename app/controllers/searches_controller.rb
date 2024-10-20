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
    calculate(:duration_percent, :invert, &:duration)
    calculate(:points_percent,   :invert) { |f| f.fare&.points }
  end

  def calculate(percent_attr, invert = false, &block)
    all = @flights.filter_map(&block)
    min, max = all.min, all.max
    hundred = max - min
    @flights.each do |flight|
      flight_val = block.call(flight)
      if flight_val
        percent = ((flight_val - min) / hundred.to_f * 100).round
        percent = 100 - percent if invert
        flight.send("#{percent_attr}=", percent)
      end
    end
  end

end
