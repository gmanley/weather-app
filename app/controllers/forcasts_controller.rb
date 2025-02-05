class ForcastsController < ApplicationController
  def show
    @forcast = Rails.cache.fetch(params[:id])
  end

  def new
  end

  # POST /forcasts or /forcasts.json
  def create
    @geolocation = Geocoder.search(forcast_params[:address]).first
    forcast_cache_key = "#{@geolocation.country_code}-#{@geolocation.postal_code}"
    forcast_cache_exist = Rails.cache.exist?(forcast_cache_key)
    @forcast = Rails.cache.fetch(forcast_cache_key, expires_in: 30.minutes) do
      WeatherService.call(
        latitude: @geolocation.latitude,
        longitude: @geolocation.longitude
      )
    end

    if @forcast
      flash[:notice] = 'Forcast pulled from cache. This updated every 30 minutes.' if forcast_cache_exist
      redirect_to "/forcasts/#{forcast_cache_key}"
    else
      flash.now[:notice] = 'Unable to retrive forcast'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def forcast_params
    params.require(:forcast).permit(:address)
  end
end
