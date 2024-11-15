require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "GET /" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end

    context "when no address present in params" do
      it "does not assign instance vars" do
        get "/"
        expect(assigns(:address)).to be_nil
        expect(assigns(:location)).to be_nil
        expect(assigns(:forecast)).to be_nil
      end
    end

    context "when address not found" do
      it "assigns @not_found" do
        expect_any_instance_of(Geolocator).to receive(:get).and_return(nil)

        get "/", params: { q: "BAD_ADDRESS" }

        expect(assigns(:not_found)).to be(true)
        expect(assigns(:address)).to eq("BAD_ADDRESS")
        expect(assigns(:location)).to be_nil
        expect(assigns(:forecast)).to be_nil
      end
    end

    context "when address is found" do
      it "should assign all instance variable" do
        fake_location = LocationInfo.new(longitude: 1, latitude: 2)
        fake_forecast = LocationForecast.new(days: [])

        expect_any_instance_of(Geolocator).to receive(:get).and_return(fake_location)
        expect_any_instance_of(Forecast).to receive(:get).and_return(fake_forecast)

        get "/", params: { q: "GOOD_ADDRESS" }

        expect(assigns(:address)).to eq("GOOD_ADDRESS")
        expect(assigns(:location)).to eq(fake_location)
        expect(assigns(:forecast)).to eq(fake_forecast)
      end
    end
  end
end
