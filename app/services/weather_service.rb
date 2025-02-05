class WeatherService
  # NOTE: Data is a new to Ruby 3.2. It's basicly struct but immutable and also supports keyword
  # args on initialization.
  class ForcastData < Data.define(:date_time, :temperature, :feels_like, :wind_speed, :humidity, :description)
    # Mixing presention logic a bit with this. Ideally this model object should just represent
    # the data and then there might be a presenter model for the view that does this but this
    # is fine for now.
    def description_display
      description.titalize
    end

    # Same as comment above. Also this is hardcoded, as the API call is hardcoded to 'Imperial'
    # right now as well. Could be changed down the line to also support metric.
    def temperature_unit
      'F'.freeze
    end
  end

  attr_reader :latitude, :longitude

  BASE_API_HOST = 'https://api.openweathermap.org'
  BASE_API_ENDPOINT = '/data/3.0/onecall'

  def initialize(latitude:, longitude:)
    @latitude = latitude
    @longitude = longitude
  end

  # WeatherService.call(latitude: 33.44, longitude: -94.04)
  def self.call(latitude:, longitude:)
    new(latitude: latitude, longitude: longitude).call
  end

  def call
    conn = Faraday.new(BASE_API_HOST) do |f|
      f.request :json # Makes JSON requests with correct content-type header
      f.request :retry # Retries certain request failures
      f.response :json # Parses JSON responses
    end
    response = conn.get(BASE_API_ENDPOINT, {
      appid: Rails.application.credentials.openweather_api_key,
      exclude: 'minutely',
      lat: latitude,
      lon: longitude,
      units: 'imperial',
    })

    body = response.body
    current = body&.dig('current')

    # TODO: Better error checking
    raise 'Request for weather failed' unless body && current

    {
      current: parse_forcast_event(current),
      hourly: body['hourly'].map { |d| parse_forcast_event(d) }
    }
  end

  private

  def parse_forcast_event(data)
    # TODO: Deal with timezone. The display of time to user should be in timezone of the location they
    # are looking up.
    date_time = Time.at(data['dt'])
    ForcastData.new(
      date_time: date_time,
      temperature: data['temp'],
      feels_like: data['feels_like'],
      wind_speed: data['wind_speed'],
      humidity: data['humidity'],
      description: data.dig('weather', 0, 'description') # Bit weird this data is an array, but it seems to always contain one element.
    )
  end
end
