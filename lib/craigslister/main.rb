# Thrown when low price is higher than high price
class InvalidRangeError < StandardError
end

# Creates url from arguments and scrapes
# https://orangecounty.craigslist.org/search/reb?min_price=50000&min_bedrooms=3&max_bedrooms=3&min_bathrooms=2&max_bathrooms=2&availabilityMode=0&sale_date=all+dates
class Craigslister
  attr_reader :area,
              :section,
              :item,
              :high,
              :low,
              :bed_min,
              :bed_max,
              :bath_min,
              :bath_max

  def initialize(args)
    @area     = args.fetch(:area, 'sfbay')
    @section  = args.fetch(:section, 'sss')
    @item     = args.fetch(:item, nil)
    @bed_min  = args.fetch(:bed_min, nil)
    @bed_max  = args.fetch(:bed_max, nil)
    @bath_min = args.fetch(:bath_min, nil)
    @bath_max = args.fetch(:bath_max, nil)
    @high     = args.fetch(:high, nil)
    @low      = args.fetch(:low, nil)

    validate_price_range
  end

  def posts
    LinkScraper.new(url, base_url).posts
  end

  def url
    "#{base_url}/search/#{section}?sort=rel&"\
    "#{price_query}&"\
    "#{bedroom_query}&"\
    "query=#{item.downcase.split(' ') * '+'}"\
  end

  private

  def base_url
    "https://#{area}.craigslist.org"
  end

  def price_query
    result = ''
    result += "min_price=#{low}&" if low
    result += "max_price=#{high}&" if high
    result
  end

  def bedroom_query
    result = ''
    result += "min_bedrooms=#{bed_min}&" if bed_min
    result += "max_bedrooms=#{bed_max}&" if bed_max
    result
  end

  def bathroom_query
    result = ''
    result += "min_bathrooms=#{bath_min}&" if bath_min
    result += "max_bathrooms=#{bath_max}&" if bath_max
    result
  end

  def validate_price_range
    fail(InvalidRangeError,
         'Price range is invalid.') if price_invalid?
  end

  def price_invalid?
    low && high && low > high
  end
end
