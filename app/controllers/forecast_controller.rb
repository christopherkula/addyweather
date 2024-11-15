class ForecastController < ApplicationController
  def main
    @address = params["q"]

    if @address.present?
      @location = Geolocator.new(address: @address).get

      if @location
        latitude = @location.latitude
        longitude = @location.longitude
        @forecast = Forecast.new(latitude: latitude, longitude: longitude).get
      else
        @not_found = true
      end
    end
  end
end
