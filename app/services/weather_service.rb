require 'ostruct'

class WeatherService

  def self.call(latitude, longitude)
    conn = Faraday.new('https://api.openweathermap.org') do |f|
      f.request :json # Makes JSON requests with correct content-type header
      f.request :retry # Retries certain request failures
      f.response :json # Parses JSON responses
    end
    response = conn.get('/data/3.0/onecall', {
      appid: Rails.application.credentials.openweather_api_key,
      exclude: 'minutely',
      lat: latitude,
      lon: longitude,
      units: 'imperial',
    })

    body = response.body
  end
end


