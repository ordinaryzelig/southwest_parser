class SearchesController < ApplicationController

  before_action :set_route_from_param, :only => %i[new destroy]

  def new
    last_cached_search = CachedSearch.last
    pre_fill_route = @route || last_cached_search&.route
    pre_fill_date  = (params[:date] || last_cached_search&.dep_on || Date.today).to_date
    @search = Search.new(
      :dep      => pre_fill_route&.dep,
      :arr      => pre_fill_route&.arr,
      :dep_on   => pre_fill_date,
      :currency => last_cached_search&.currency || :points,
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
        .available
        .route(@route)
        .includes(:fare)
    @calcs = FlightsCalculations.new(@flights).tap(&:call)
    set_filter_settings
  end

  def destroy
    Flight
      .route(@route)
      .dep_date(params[:date]) # NOTE This is wrong because of time zone.
      .destroy_all
    redirect_to search_path(@route)
  end

  def load_cached
    cached_search = CachedSearch.new(params[:path])
    cached_search.load
    redirect_to search_path(cached_search.route)
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
    @route = Route.from_string(params[:route]) if params[:route]
  end

  def set_filter_settings
    @filter_settings = {
      :dep => {
        :min => @calcs.dep_min,
        :max => @calcs.dep_max,
      },
      :arr => {
        :min => @calcs.arr_min,
        :max => @calcs.arr_max,
      },
      :duration => {
        :min => @calcs.duration_min,
        :max => @calcs.duration_max,
      },
      :stops => {
        :min => @calcs.stops_min,
        :max => @calcs.stops_max,
      },
      :kpoints => {
        :min => @calcs.kpoints_min,
        :max => @calcs.kpoints_max,
      },
    }
  end

  def cached_searches
    @cached_searches ||= CachedSearch.where(
      :route => params[:route],
      :date  => params[:date],
    )
  end
  helper_method :cached_searches

end
