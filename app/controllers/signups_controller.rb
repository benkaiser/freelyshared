class SignupsController < ApplicationController
  def interest
    @suburb = params[:suburb]
    @lat = params[:lat]&.to_f
    @lng = params[:lng]&.to_f

    if @lat && @lng
      @signup_count = GeographicSignup.within_radius(@lat, @lng, 50).count
      @geographic_signup = GeographicSignup.new(
        suburb_name: @suburb,
        latitude: @lat,
        longitude: @lng
      )
    else
      redirect_to root_path, alert: "Invalid location data"
    end
  end

  def create
    @geographic_signup = GeographicSignup.new(signup_params)

    if @geographic_signup.save
      # In a real app, you'd send a verification email here
      redirect_to thankyou_path(id: @geographic_signup.id)
    else
      @suburb = @geographic_signup.suburb_name
      @lat = @geographic_signup.latitude
      @lng = @geographic_signup.longitude
      @signup_count = GeographicSignup.within_radius(@lat, @lng, 50).count if @lat && @lng
      render :interest, status: :unprocessable_entity
    end
  end

  def thankyou
    @geographic_signup = GeographicSignup.find(params[:id])
    @share_url = interest_url(
      suburb: @geographic_signup.suburb_name,
      lat: @geographic_signup.latitude,
      lng: @geographic_signup.longitude
    )
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  private

  def signup_params
    params.require(:geographic_signup).permit(:name, :email, :suburb_name, :latitude, :longitude, :country_code, :state_code, :postcode)
  end
end
