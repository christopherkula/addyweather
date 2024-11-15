# Cache raw JSON for an address
class GeolocatorCache
  # Redis-managed entry expiration
  EXPIRE_IN = 30.minutes
  attr_reader :address

  # +address+: [String]
  def initialize(address:)
    @address = address
  end

  # Caches info for address unless already exists
  def set(data)
    $redis.set(key, data, nx: true, ex: EXPIRE_IN)
  end

  # Fetch from Redis
  def get
    $redis.get(key)
  end

  private

  # Redis key for address
  def key
    return @key if @key # was memoized

    canonical = address
                .gsub(/[[:punct:]]/, " ") # remove punctuation
                .gsub(/\s+/, " ") # standardize whitespace
                .downcase
                .strip

    @key = "address:#{canonical}"
  end
end
