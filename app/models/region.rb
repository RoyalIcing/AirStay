class Region < ApplicationRecord
  include ActiveModel::Validations
  include Weather

  class CountryCodeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      # `value` should be an alpha2 country code
      country = ISO3166::Country.new(value)
      # Double check for country not being nil, and also being a valid country code
      record.errors.add attribute, "must be valid alpha 2 country code" unless country.present? and country.valid?
    end
  end

  has_many :listings

  validates :name, presence: true
  validates :country_code, presence: true, length: { is: 2 }, country_code: true
  before_save :downcase_country_code

  def country
    ISO3166::Country.new(country_code)
  end

  def address(prefix = nil)
    # e.g.
    # 123 Example St, Melbourne, Australia
    # Melbourne, Australia
    [prefix, name, country.name].select(&:present?).join(', ')
  end

  def weather
    Region.load_weathers_for([self]) if @weather.nil?
    @weather
  end

  def self.load_weathers_for(regions)
    weathers = self.weathers_for_addresses(regions.map(&:address))
    regions.each do |region|
      city = region.name
      country_name = region.country.name
      weather = weathers.find { |weather| weather.dig('location', 'city') == city and weather.dig('location', 'country') == country_name }
      if weather.present?
        region.weather = weather
      end
    end
  end

  def weather=(weather)
    @weather = weather
  end

  private
    def downcase_country_code
      self.country_code = self.country_code.downcase
    end
end
