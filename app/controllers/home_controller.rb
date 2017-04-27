class HomeController < ApplicationController
  def index
    if user_signed_in?
      @profile = current_user.profile
      # If user has just signed up, make them fill out their profile
      redirect_to new_profile_url if @profile.nil?
    end

    @random_region = Region.offset(rand(Region.count)).first
  end
end
