# NOTE: Data is a new to Ruby 3.2. It's basically  a struct but immutable and also supports keyword
# args on initialization.
class ForcastData < Data.define(:date_time, :temperature, :feels_like, :wind_speed, :humidity, :description)
  # Mixing presention logic a bit with this. Ideally this model object should just represent
  # the data and then there might be a presenter model for the view that does this but this
  # is fine for now.
  def date_time_display
    date_time.strftime("%a %I:%M %P")
  end

  def description_display
    description.titleize
  end

  # Also this is hardcoded, as the API call is hardcoded to 'Imperial'
  # right now as well. Could be changed down the line to also support metric.
  def temperature_unit
    'F'.freeze
  end
end