require 'rails_helper'

RSpec.describe "forecast/main.html.erb", type: :view do
  context "when address search is not successful" do
    before(:each) { assign(:not_found, true) }

    it "displays a not-found message" do
      render
      expect(rendered).to include("address not found!")
    end
  end

  context "when no location has been queried" do
    it "does not display an error message" do
      render
      expect(rendered).not_to include("address not found!")
    end
  end

  context "when a location has been successfully queried" do
    let(:from_cache) { false }

    before(:each) do
      assign(:location,
        LocationInfo.new(
          city: "Slippery Falls",
          region: "Virginia",
          country: "United States"
        )
      )
      assign(:forecast,
        LocationForecast.new(
          days: [
            DailyWeather.new("2024-11-15".to_date, 51, 53.7, 44.1),
            DailyWeather.new("2024-11-16".to_date, 3, 56.6, 40.8)
          ],
          from_cache: from_cache
        )
      )
    end

    it "displays the location name" do
      render
      expect(rendered).to include("Slippery Falls")
      expect(rendered).to include("Virginia")
      expect(rendered).to include("United States")
    end

    it "displays daily weather reports" do
      render
      assert_select ".daily-forecast", count: 2
    end

    it "display weather report info" do
      render
      assert_select ".weekday", text: "Friday"
      assert_select ".weekday", text: "Saturday"
      assert_select ".date", text: "Nov. 15, 2024"
      assert_select ".date", text: "Nov. 16, 2024"
      assert_select ".description", text: "light drizzle"
      assert_select ".description", text: "overcast"
      assert_select ".temperatures", text: "low: 44.1 / high: 53.7"
      assert_select ".temperatures", text: "low: 40.8 / high: 56.6"
    end

    it "does not display the cache indicator" do
      render
      expect(rendered).not_to include("previously cached")
    end

    context "when pulled from cache" do
      let(:from_cache) { true }

      it "displays the cache indicator" do
        render
        expect(rendered).to include("previously cached")
      end
    end
  end
end
