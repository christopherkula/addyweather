require 'rails_helper'
require 'mock_redis'

RSpec.describe GeolocatorCache, type: :model do
  let(:service) { GeolocatorCache.new(address: "1600 Pennsylvania Avenue, Washington, D.C.") }
  let(:json) { '[{"dummy": "data"}]' }

  before(:all) do
    $redis = MockRedis.new # don't rely on active Redis server
  end

  it "returns nil if address is not cached" do
    expect(service.get).to be_nil
  end

  it "stores location data for an address" do
    service.set(json)
    expect(service.get).to eq(json)
  end

  it "finds data for a canonically equivalent address" do
    service.set(json)
    equivalent_address = " 1600 Pennsylvania Avenue Washington d. c."
    service_2 = GeolocatorCache.new(address: equivalent_address)
    expect(service_2.get).to eq(json)
  end
end
