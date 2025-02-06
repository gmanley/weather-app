class WeatherService
  class APIError < StandardError; end

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

    unless response.success?
      raise APIError, "API request failed: status code #{response.status}"
    end

    body = response.body
    if body.present? && body['current'].present?
      {
        current: parse_forcast_event(body['current']),
        hourly: body['hourly'].map { |d| parse_forcast_event(d) }
      }
    else
      raise APIError, 'API request failed: response body invalid'
    end
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
