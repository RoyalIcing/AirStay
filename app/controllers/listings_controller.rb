class ListingsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :require_host_signed_in, only: [:edit, :update, :destroy]
  before_action :set_countries, only: [:new, :edit]

  # GET /listings
  # GET /listings.json
  def index
    region_name = params[:region_name]
    country_code = params[:country_code]
    
    # Filter by region name or country
    if region_name.present? or country_code.present?
      @regions = Region.all
      @regions = @regions.name_eq(region_name) if region_name.present?
      @regions = @regions.country_code_eq(country_code) if country_code.present?
      @listings = Listing.where(region: @regions)

      @country = ISO3166::Country.new(country_code) if country_code.present?
    else
      # Show all listings
      @listings = Listing.all
    end

    # Filter by host
    host_id = params[:host]
    @listings = @listings.where(host_id: host_id) if host_id.present?
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
    @earliest_available_date = @listing.earliest_available_date

    @service_fee_cents = Listing.service_fee_cents

    if @earliest_available_date
      @provision = @listing.provision_for_date(@earliest_available_date)

      if user_signed_in?
        # Use dates from query: ?check_in=_&check_out=_
        check_in_date = params[:check_in].try{ |s| Date.parse(s) } || @earliest_available_date
        check_out_date = params[:check_out].try{ |s| Date.parse(s) } || (@earliest_available_date + @provision.nights_min)
        guest_count = params.fetch(:guest, 1)

        @new_trip = Trip.new(
          guest: current_user,
          listing: @listing,
          check_in_date: check_in_date,
          check_out_date: check_out_date,
          guest_count: guest_count
        )
        @new_trip.validate(:display)

        @nights_count = @new_trip.check_out_date - @new_trip.check_in_date 
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end

  # GET /listings/1/edit
  def edit
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(host: current_user)

    address_hash = address_params
    region = nil
    Region.transaction(requires_new: true) do
      region = Region.country_code_eq(address_hash[:region_country_code_upper]).name_eq(address_hash[:city_name]).first
      region = Region.create!(country_code: address_hash[:region_country_code_upper], name: address_hash[:city_name]) if region.nil?
    end

    address = region.address(address_hash[:street])

    @listing.region = region
    @listing.address = address

    @provision = ListingProvision.new(
      listing: @listing,
      start_date: Date.new(2001),
      guests_max: 1,
      bed_count: 1,
      nights_min: 1,
      nightly_fee_cents: 100,
      cleaning_fee_cents: 20
    )

    respond_to do |format|
      if @listing.save and @provision.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    def set_countries
      @countries = ISO3166::Country.codes.map{ |alpha2| ISO3166::Country.new(alpha2) }
    end

    def require_host_signed_in
      redirect_to listings_url unless @listing.host == current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def address_params
      params.require(:listing).permit(:region_country_code_upper, :city_name, :street)
    end
end
