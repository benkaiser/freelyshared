class ChurchMembers::RegistrationsController < Devise::RegistrationsController
  # Disable standard sign-up — users must join via church flow
  def new
    redirect_to root_path, alert: "Please join a church to create an account."
  end

  def create
    redirect_to root_path, alert: "Please join a church to create an account."
  end

  protected

  def after_update_path_for(resource)
    profile_path
  end
end
