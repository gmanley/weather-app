require 'rails_helper'

RSpec.describe 'Looking up forcast', type: :system do
  include_context 'with cache'

  context 'when address is invalid' do
    around do |example|
      Geocoder::Lookup::Test.add_stub(
        'bad address', []
      )
      example.run
      Geocoder::Lookup::Test.reset
    end

    it 'should render "Invalid address" on page' do
      visit '/'
      fill_in 'forcast_address', with: 'bad address'
      click_button 'Get forcast'
      expect(page).to have_content('Invalid address')
    end
  end

  context 'when address is valid' do
    around do |example|
      Geocoder::Lookup::Test.add_stub(
        '1 Apple Park Way. Cupertino, CA 95014', [
          {
            'coordinates'  => [37.3362065, -122.006996],
            'address'      => '1 Apple Park Way. Cupertino, CA 95014',
            'state'        => 'California',
            'state_code'   => 'CA',
            'country'      => 'United States',
            'country_code' => 'us',
            'postal_code'  => '95014'
          }
        ]
      )
      example.run
      Geocoder::Lookup::Test.reset
    end

    context 'when retreival of forcast data is unsuccessful' do
      before do
        stub_request(:get, %r[#{WeatherService::BASE_API_HOST}]).to_return(status: 500)
      end

      it 'should display forcast data' do
        visit '/'
        fill_in 'forcast_address', with: '1 Apple Park Way. Cupertino, CA 95014'
        click_button 'Get forcast'
        expect(page).to have_content('Unable to retrive forcast')
      end
    end

    context 'when retreival of forcast data is successful' do
      before do
        stub_request(:get, %r[#{WeatherService::BASE_API_HOST}]).to_return(
          status: 200,
          body: load_fixture('openweather_one_call_success.json'),
          headers: { 'content-type' => 'application/json' }
        )
      end

      it 'should display forcast data' do
        visit '/'
        fill_in 'forcast_address', with: '1 Apple Park Way. Cupertino, CA 95014'
        click_button 'Get forcast'
        expect(page).to have_content('Scattered Clouds')
      end
    end
  end
end
