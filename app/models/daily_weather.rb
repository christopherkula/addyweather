# Weather forecast information for a single day
class DailyWeather < Struct.new(:date, :code, :high, :low)
  # https://open-meteo.com/en/docs
  CODES = {
    0 => "clear",
    1 => "mostly clear",
    2 => "partly cloudy",
    3 => "overcast",
    45 => "foggy",
    48 => "freezing fog",
    51 => "light drizzle",
    53 => "moderate drizzle",
    55 => "heavy drizzle",
    56 => "light freezing drizzle",
    57 => "heavy freezing drizzle",
    61 => "light rain",
    63 => "moderate rain",
    65 => "heavy rain",
    66 => "light freezing rain",
    67 => "heavy freezing rain",
    71 => "light snowfall",
    73 => "moderate snowfall",
    75 => "heavy snowfall",
    77 => "grainy snow",
    80 => "light showers",
    81 => "moderate showers",
    82 => "violent showers",
    85 => "light snow showers",
    86 => "heavy snow showers",
    95 => "moderate thunderstorms",
    96 => "thunderstorms with light hail",
    99 => "thunderstorms with heavy hail"
  }

  # Instance method to convert the returned code
  # to its English language description.
  def description
    CODES[code]
  end
end
