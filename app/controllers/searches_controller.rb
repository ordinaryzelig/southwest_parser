class SearchesController < ApplicationController

  before_action :set_route_from_param, :only => %i[new destroy]

  def new
    @search = Search.new(
      :dep      => @route.dep,
      :arr      => @route.arr,
      :dep_on   => params.fetch(:date, Date.new(2024, 10, 24)).to_date,
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
    @calcs = FlightsCalculations.new(@flights).tap(&:call)
  end

  def destroy
    Flight
      .route(@route)
      .dep_date(params[:date]) # NOTE This is wrong because of time zone.
      .destroy_all
    redirect_to search_path(@route)
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

  def set_route_from_param
    @route = Route.from_string(params[:route])
  end

end
