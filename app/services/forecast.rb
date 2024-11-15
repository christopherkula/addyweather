# Service to invoke weather forecast API
# Uses ForecastCache service for caching results.
class Forecast
  API_URL = "https://api.open-meteo.com/v1/forecast"
  API_PARAMS = {
    current: "is_day",
    daily: %w[weather_code temperature_2m_max temperature_2m_min],
    temperature_unit: "fahrenheit",
    wind_speed_unit: "mph",
    precipitation_unit: "inch",
    timezone: "auto"
  }

  attr_reader :latitude, :longitude

  # +latitude+: [Float] latitude in degrees
  # +longitude+: [Float] longitude in degrees
  def initialize(latitude:, longitude:)
    @latitude = latitude
    @longitude = longitude
  end

  # Returns location forecast with an array of days of weather forecasts.
  def get
    data = fetch

    LocationForecast.new(
      latitude: data["latitude"],
      longitude: data["longitude"],
      zone: data["timezone_abbreviation"],
      elevation: data["elevation"],
      days: parse_days(data["daily"])
    )
  end

  private

  # Transforms API results into an array of DailyWeather objects
  # Note that it takes the contents of the "daily" key as input.
  def parse_days(daily_data)
    dates = daily_data["time"].map(&:to_date)
    codes = daily_data["weather_code"]
    highs = daily_data["temperature_2m_max"]
    lows  = daily_data["temperature_2m_min"]

    dates.each_with_index.map do |date, index|
      DailyWeather.new(
        date: date,
        code: codes[index],
        high: highs[index],
        low: lows[index]
      )
    end
  end

  # Fetches new or cached (if exists) data from weather forecast service.
  # * Checks for a cached result
  # * If none, calls API and sets cache
  # * Parses and returns result
  def fetch
    cache_service = ForecastCache.new(latitude: latitude, longitude: longitude)
    json = cache_service.get

    if !json
      # No match found - fetch from API and add to cache.
      json = fetch_from_api
      cache_service.set(json)
    end

    JSON.parse(json)
  end

  # Raw API call, returning JSON
  def fetch_from_api
    parameters = API_PARAMS.merge(latitude: latitude, longitude: longitude)
    Faraday.get(API_URL, parameters, { "Accept" => "application/json" }).body
  end
end
