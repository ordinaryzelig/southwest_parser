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
    @flights = Flight.route(@route)
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

end
