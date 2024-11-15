# Service to convert freeform address to latitude / longitude
class Geolocator
  API_URL = "https://geocode.maps.co/search"
  API_KEY = Rails.application.credentials.dig(:geocode_maps_co, :api_key)

  attr_reader :address

  # +address+: [String] street address
  def initialize(address:)
    @address = address
  end

  # Parses result into LocationInfo object
  def get
    data = fetch

    return nil unless data # no match

    segments = data["display_name"].split(/,\s*/).reverse
    # Till starting from country end. Number and/or street can sometimes be missing.
    country, postal_code, region, county, city, district, street, number = segments

    LocationInfo.new(
      latitude: data["lat"].to_f,
      longitude: data["lon"].to_f,
      number: number,
      street: street,
      district: district,
      city: city,
      county: county,
      region: region,
      postal_code: postal_code,
      country: country
    )
  end

  # Fetches new or cached (if exists) address data.
  # * Checks for a cached result
  # * If none, calls API and sets cache
  # * Parses and returns result
  def fetch
    cache_service = GeolocatorCache.new(address: address)
    json = cache_service.get

    if !json
      # No match found - fetch from API and add to cache.
      json = fetch_from_api
      cache_service.set(json)
    end

    # Use first result if multiple were returned. If no results, will return `nil`.
    JSON.parse(json).first
  end

  private

  # Raw API call, returning JSON.
  # Note that it returns an array of typically one result.
  def fetch_from_api
    parameters = { q: address, api_key: API_KEY }
    response = Faraday.get(API_URL, parameters, { "Accept" => "application/json" })
    response.body
  end
end
