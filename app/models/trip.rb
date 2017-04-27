class Trip < ApplicationRecord
  belongs_to :guest, class_name: 'User'
  belongs_to :listing
  has_many :reviews

  class CheckedDatesValidator < ActiveModel::Validator
    def validate(record)
      attributes = options.fetch(:attributes)
      start_date = record[attributes[0]]
      end_date = record[attributes[1]]
      record.errors.add(:base, "#{attributes[0]} must be earlier than #{attributes[1]}") unless start_date < end_date
    end
  end

  validates :check_in_date, :check_out_date, overlap: {
    scope: 'listing_id',
    exclude_edges: [:check_in_date, :check_out_date]
  }, checked_dates: true
  validates :stripe_charge_id, presence: true, on: :create

  scope :with_listing, -> (listing) { where(listing: listing) }
  scope :out_after_date, -> (date) { where('check_out_date >= ?', date) }
  scope :in_before_date, -> (date) { where('check_in_date < ?', date) }

  def nights_count
    (check_out_date - check_in_date).to_i
  end

  # Find available trip dates for a particular listing
  def self.available_date_ranges_for_listing(listing, days_ahead, start_date)
    end_date = start_date + days_ahead

    trips = self.with_listing(listing).out_after_date(start_date).in_before_date(end_date)

    # Using the trip dates, find all dates in between that are available
    available_dates = []
    prev_end_date = nil
    trips.each do |trip|
      available_dates << Range.new(prev_end_date, trip.check_in_date, true) if prev_end_date
      prev_end_date = trip.check_out_date
    end

    available_dates << Range.new(prev_end_date, end_date, true) if prev_end_date
    available_dates << Range.new(start_date, end_date, true) if available_dates.empty?

    available_dates
  end

  def self.earliest_available_date_for_listing(listing, days_ahead, start_date)
    date_ranges = available_date_ranges_for_listing(listing, days_ahead, start_date)
    date_ranges.first.try(:min)
  end

  # Calculate the cost over a trip’s duration
  def cost
    TripCost.new(listing, check_in_date, check_out_date) if valid?(:display)
  end
end
