require 'rails_helper'

RSpec.describe DailyWeather, type: :model do
  it "returns a text description of weather conditions" do
    daily_weather = DailyWeather.new(code: 45)

    expect(daily_weather.description).to eq("foggy")
  end
end
