class Listing < ApplicationRecord
  belongs_to :host, class_name: 'User'
  belongs_to :region
  has_many :trips
  has_many :reviews

  validates :address, presence: true

  geocoded_by :address, latitude: :lat, longitude: :lng
  after_validation :geocode

  def region_country_code_upper
    region.try(:country_code).try(:upcase)
  end

  def city_name
    region.try(:name)
  end

  def street
    # Remove city and country
    address.try { |address| address.split(',').reverse.drop(2).map(&:strip).reverse.join(', ') }
  end

  def self.service_fee_cents
    10_00
  end

  # Provisions

  def provisions
    ListingProvision.by_listing(self)
  end

  def provision_for_date(date)
    provisions.starting_from(date).limit(1).first
  end

  # Trips

  DEFAULT_DAYS_AHEAD = 30

  def available_date_ranges(days_ahead, start_date)
    Trip.available_date_ranges_for_listing(self, days_ahead, start_date)
  end

  def earliest_available_date(days_ahead = DEFAULT_DAYS_AHEAD)
    @earliest_date_available ||= Trip.earliest_available_date_for_listing(self, days_ahead, Date.today)
  end

  def cost_for_earliest_available_date(days_ahead = DEFAULT_DAYS_AHEAD)
    date = earliest_available_date(days_ahead)
    return nil unless date
    TripCost.new(self, date, date + 1)
  end

  def nightly_fee_for_earliest_available_date(days_ahead = DEFAULT_DAYS_AHEAD)
    cost_for_earliest_available_date(days_ahead).try{ |cost| cost.night_fees.first }
  end
end
