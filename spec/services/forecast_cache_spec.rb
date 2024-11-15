require "rails_helper"
require "mock_redis"

RSpec.describe ForecastCache, type: :model do
  let(:latitude) { 39 }
  let(:longitude) { -77 }
  let(:service) { ForecastCache.new(latitude: latitude, longitude: longitude) }
  let(:json) { '[{"dummy": "data"}]' }

  before(:all) do
    $redis = MockRedis.new # do not hit or require an active Redis server
  end

  it "returns nil if forecast is not cached" do
    expect(service.get).to be_nil
  end

  it "stores forecast data for a set of coordinated" do
    service.set(json)
    expect(service.get).to eq(json)
  end

  it "returns data for a nearby location (within ~1km)" do
    service.set(json)
    service_2 = ForecastCache.new(latitude: latitude + 0.009, longitude: longitude + 0.009)
    expect(service_2.get).to eq(json)
  end

  it "returns nil if more than ~1km latitudinal difference" do
    service.set(json)
    service_2 = ForecastCache.new(latitude: latitude + 0.011, longitude: longitude)
    expect(service_2.get).to be_nil
  end

  it "returns nil if more than ~1km longitudinal difference" do
    service.set(json)
    service_2 = ForecastCache.new(latitude: latitude, longitude: longitude + 0.011)
    expect(service_2.get).to be_nil
  end
end
