class ForcastsController < ApplicationController
  def show
    # NOTE: Not ideal as it uses the cache as a sort of persistance layer, instead of as just a cache.
    # Since this is user input, do basic validation on cache key to make sure it's not garbage
    validate_cache_key!(params[:id])
    @forcast = Rails.cache.fetch(params[:id])

    unless @forcast
      redirect_to root_path
    end
  end

  def new
  end

  def create
    @geolocation = Geocoder.search(forcast_params[:address]).first

    unless @geolocation
      flash.now[:notice] = 'Invalid address'
      render :new, status: :unprocessable_entity
      return
    end

    forcast_cache_key = "#{@geolocation.country_code}-#{@geolocation.postal_code}"
    forcast_cache_exist = Rails.cache.exist?(forcast_cache_key)
    @forcast = Rails.cache.fetch(forcast_cache_key, expires_in: 30.minutes) do
      begin
        WeatherService.call(
          latitude: @geolocation.latitude,
          longitude: @geolocation.longitude
        )
      rescue WeatherService::APIError
        nil
      end
    end

    if @forcast
      if forcast_cache_exist
        flash[:notice] = 'This forcast data has been retrieved from information that may be up to 30 minutes delayed.'
      end

      redirect_to "/forcasts/#{forcast_cache_key}"
    else
      flash.now[:notice] = 'Unable to retrive forcast'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def validate_cache_key!(cache_key)
    # TODO: This is assuming support for just US.
    unless cache_key.match?(/^us-\d{5}$/)
      raise 'Invalid cache key'
    end
  end

  def forcast_params
    params.require(:forcast).permit(:address)
  end
end

