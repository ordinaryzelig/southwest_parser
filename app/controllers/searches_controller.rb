class SearchesController < ApplicationController

  def new
  end

  def create
    json = JSON.load(params[:json])
    parsed_flights = SearchJsonParser.parse_all(json)
    flights = SearchPersister.new(parsed_flights).call
    redirect_to searches_path(parsed_flights.first.route)
  end

  def show
    @route = Route.from_string(params[:id])
    @flights = Flight.route(@route)
  end

end
