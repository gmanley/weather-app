require 'rails_helper'

RSpec.describe WeatherService do
  describe '#call' do
    let(:result) { described_class.new(latitude: 33.44, longitude: -94.04).call }

    context 'when call to API returns a non 200 status code' do
      let(:status_code) { 500 }
      before do
        stub_request(:get, %r[#{described_class::BASE_API_HOST}]).to_return(status: status_code)
      end

      it 'raises an exception' do
        expect { result }.to raise_error(described_class::APIError, "API request failed: status code #{status_code}")
      end
    end

    context 'when call to API returns an empty body' do
      before do
        stub_request(:get, %r[#{described_class::BASE_API_HOST}]).to_return(
          status: 200,
          body: "[]",
          headers: { 'content-type' => 'application/json' }
        )
      end

      it 'raises an exception' do
        expect { result }.to raise_error(described_class::APIError, 'API request failed: response body invalid')
      end
    end

    context 'when call to API returns a body without current weather data' do
      before do
        stub_request(:get, %r[#{described_class::BASE_API_HOST}]).to_return(
          status: 200,
          body: '{ "lat": 33.44, "lon": -94.04 }',
          headers: { 'content-type' => 'application/json' }
        )
      end

      it 'raises an exception' do
        expect { result }.to raise_error(described_class::APIError, 'API request failed: response body invalid')
      end
    end

    context 'when call to API is successful' do
      before do
        stub_request(:get, %r[#{described_class::BASE_API_HOST}]).to_return(
          status: 200,
          body: load_fixture('openweather_one_call_success.json'),
          headers: { 'content-type' => 'application/json' }
        )
      end

      it 'returns an object where current forcast time is accessible' do
        expect(result[:current].date_time).to be_an_instance_of(Time)
      end

      it 'returns an object where current forcast temperature is accessible' do
        expect(result[:current].temperature).to be_an_instance_of(Float)
      end

      it 'returns an object where current forcast feels like is accessible' do
        expect(result[:current].feels_like).to be_an_instance_of(Float)
      end

      it 'returns an object where current forcast feels like is accessible' do
        expect(result[:current].feels_like).to be_an_instance_of(Float)
      end

      it 'returns an object where current forcast wind speed is accessible' do
        expect(result[:current].wind_speed).to be_an_instance_of(Float)
      end

      it 'returns an object where current forcast humidity is accessible' do
        expect(result[:current].humidity).to be_an_instance_of(Integer)
      end

      it 'returns an object where current forcast description is accessible' do
        expect(result[:current].description).to be_an_instance_of(String)
      end

      # NOTE: Generally think there isn't a need to check each of the setting of forcast data again,
      # just one of them. Could be more comprehensive and use a shared example "it_behaves_like" setup,
      # but seems overkill.
      it 'returns an object where an hourly list of forcast info is accessable' do
        expect(result[:hourly].first.temperature).to be_an_instance_of(Float)
      end
    end
  end
end
