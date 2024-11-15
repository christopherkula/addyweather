# Caches raw JSON for a specific latitude and longitude
# The caching is "fuzzy". It will return a match within
# about a kilometer of the current query.
class ForecastCache
  # Redis-managed entry expiration
  EXPIRE_IN = 30.minutes

  # Matches cached reports within this approximate lat and lng distance
  FUZZY_DISTANCE_KM = 1

  # Approximate conversion of lat/lng to kilometers.
  # This is within about 25% accuracy for non-arctic coordinates.
  # The Haversine Formula or the Equirectangular Approximation
  # would be more exact, but are certainly overkill for this
  # approximate science.
  APPROX_KM_PER_DEGREE = 100

  attr_reader :latitude, :longitude

  # +latitude+: [Float] latitude in degrees
  # +longitude+: [Float] longitude in degrees
  def initialize(latitude:, longitude:)
    @latitude = latitude
    @longitude = longitude
  end

  # Caches info for location unless already exists
  def set(data)
    $redis.set("lat:#{latitude},lng:#{longitude}", data, nx: true, ex: EXPIRE_IN)
  end

  # Scans Redis keys for an approximate coordinate match
  def get
    $redis.scan_each(match: "lat:*,lng:*") do |key|
      # extract coordinates from key
      matches = /^lat\:(.+),lng\:(.+)$/.match(key)
      key_coordinates = [ matches[1].to_f, matches[2].to_f ]

      # return data if coordinates match or are near search coordinates
      return $redis.get(key) if near?(*key_coordinates)
    end

    nil # no match found
  end

  # Scans an approximately 2km by 2km *box* around the search coordinates.
  # Could be quickly and not-too-expensively improved by a circular check.
  # But, really... just trying to catch the next-door neighbors here.
  def near?(cached_latitude, cached_longitude)
    return false if (latitude - cached_latitude).abs * APPROX_KM_PER_DEGREE > FUZZY_DISTANCE_KM
    return false if (longitude - cached_longitude).abs * APPROX_KM_PER_DEGREE > FUZZY_DISTANCE_KM

    true # within matching box
  end
end
