class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_church, :impersonating?

  after_action :track_page_view

  private

  def current_church
    current_church_member&.church
  end

  def authenticate_member!
    unless church_member_signed_in?
      redirect_to new_church_member_session_path, alert: "Please sign in to continue."
    end
  end

  def impersonating?
    session[:superadmin_id].present?
  end

  def track_page_view
    return unless request.get? && response.successful?
    return if request.path.start_with?("/up", "/assets", "/superadmin")
    return if request.xhr?

    section = case controller_name
    when "pages" then "home"
    when "items" then "items"
    when "services_listings" then "services"
    when "needs" then "needs"
    when "profiles" then "profile"
    when "members" then "members"
    when "dashboard" then "dashboard"
    when "churches" then "churches"
    else controller_name
    end

    TelemetryEvent.track("page_view",
      member: current_church_member,
      metadata: { section: section, path: request.path }
    )
  end
end
