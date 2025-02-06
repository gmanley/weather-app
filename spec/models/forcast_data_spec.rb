require 'rails_helper'

RSpec.describe ForcastData do
  subject(:forcast_data) do
    ForcastData.new(
      date_time: Time.parse('April 14, 1965 14:58'),
      temperature: 65.3,
      feels_like: 60.1,
      wind_speed: 10.2,
      humidity: 20,
      description: 'tons of snow'
    )
  end

  describe '#date_time_display' do
    it 'returns a 12 hour time representation with day of week' do
      expect(forcast_data.date_time_display).to eq('Wed 02:58 pm')
    end
  end

  describe '#description_display' do
    it 'returns description titalized' do
      expect(forcast_data.description_display).to eq('Tons Of Snow')
    end
  end
end
