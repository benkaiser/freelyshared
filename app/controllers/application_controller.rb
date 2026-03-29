class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_church

  private

  def current_church
    current_church_member&.church
  end

  def authenticate_member!
    unless church_member_signed_in?
      redirect_to new_church_member_session_path, alert: "Please sign in to continue."
    end
  end
end
