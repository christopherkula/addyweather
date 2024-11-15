require "rails_helper"
require "mock_redis"

RSpec.describe Geolocator, type: :model do
  let(:address) { "300 Alamo Plaza, San Antonio, TX 78205" }
  let(:service) { Geolocator.new(address: address) }
  let(:json) { "[{\"lat\":\"29.425693850000002\",\"lon\":\"-98.48568711999474\",\"display_name\":\"The Alamo, 300, Alamo Plaza, Downtown, San Antonio, Bexar County, Texas, 78205, United States\"}]" }
  let(:location_info_attributes) { {
    latitude: 29.425693850000002,
    longitude: -98.48568711999474,
    number: "300",
    street: "Alamo Plaza",
    district: "Downtown",
    city: "San Antonio",
    county: "Bexar County",
    region: "Texas",
    postal_code: "78205",
    country: "United States"
  } }

  it "populates LocationInfo from an API call" do
    # stubbing this out lazily within the service object
    expect(service).to receive(:fetch_from_api).and_return(json)

    expect(service.get.to_h).to eq(location_info_attributes)
  end

  it "populates LocationInfo from cache" do
    expect_any_instance_of(GeolocatorCache).to receive(:get).and_return(json)

    expect(service.get.to_h).to eq(location_info_attributes)
  end
end
