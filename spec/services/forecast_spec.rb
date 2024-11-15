require "rails_helper"
require "mock_redis"

RSpec.describe Forecast, type: :model do
  let(:latitude) { 38.890526 }
  let(:longitude) { -77.02716 }
  let(:service) { Forecast.new(latitude: latitude, longitude: longitude) }
  let(:json) { '{"latitude":38.890526,"longitude":-77.02716,"generationtime_ms":0.1310110092163086,"utc_offset_second":-18000,"timezone":"America/New_York","timezone_abbreviation":"EST","elevation":19.0,"current_units":{"time":"iso8601","interval":"seconds","is_day":""},"current":{"time":"2024-11-15T11:45","interval":900,"is_day":1},"daily_units":{"time":"iso8601","weather_code":"wmo code","temperature_2m_max":"°F","temperature_2m_min":"°F"},"daily":{"time":["2024-11-15","2024-11-16"],"weather_code":[51,3],"temperature_2m_max":[53.7,56.6],"temperature_2m_min":[44.1,40.8]}}' }
  let(:forecast_attributes) { {
    :latitude=>38.890526,
    :longitude=>-77.02716,
    :zone=>"EST",
    :elevation=>19.0,
    :days=>[
      DailyWeather.new("2024-11-15", 51, 53.7, 44.1),
      DailyWeather.new("2024-11-16", 3, 56.6, 40.8)
    ]
  } }

  it "populates LocationForecast from an API call" do
    # stubbing this out lazily within the service object
    expect(service).to receive(:fetch_from_api).and_return(json)

    expect(service.get.to_h).to eq(forecast_attributes)
  end

  it "populates LocationInfo from cache" do
    expect_any_instance_of(ForecastCache).to receive(:get).and_return(json)

    expect(service.get.to_h).to eq(forecast_attributes)
  end
end
