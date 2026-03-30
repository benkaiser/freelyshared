class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_church, :current_membership, :impersonating?, :pending_borrow_requests_count

  after_action :track_page_view

  private

  def current_church
    return @current_church if defined?(@current_church)

    @current_church = if church_member_signed_in?
      if session[:current_church_id].present?
        church = Church.find_by(id: session[:current_church_id])
        if church && current_church_member.member_of?(church)
          church
        else
          session.delete(:current_church_id)
          fallback_church
        end
      else
        fallback_church
      end
    end
  end

  def current_membership
    return @current_membership if defined?(@current_membership)

    @current_membership = if church_member_signed_in? && current_church
      current_church_member.membership_for(current_church)
    end
  end

  def fallback_church
    church = current_church_member.church # legacy default
    if church && current_church_member.member_of?(church)
      session[:current_church_id] = church.id
      church
    else
      first_church = current_church_member.approved_churches.first
      if first_church
        session[:current_church_id] = first_church.id
        first_church
      end
    end
  end

  def pending_borrow_requests_count
    return @pending_borrow_requests_count if defined?(@pending_borrow_requests_count)

    @pending_borrow_requests_count = if church_member_signed_in?
      BorrowRequest.pending
        .joins(:item)
        .where(items: { church_member_id: current_church_member.id })
        .count
    else
      0
    end
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
