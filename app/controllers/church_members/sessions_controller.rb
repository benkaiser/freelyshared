class ChurchMembers::SessionsController < Devise::SessionsController
  after_action :track_login, only: :create
  after_action :track_failed_login, only: :create, if: -> { response.status == 401 || flash[:alert].present? }

  protected

  def after_sign_in_path_for(resource)
    # Set the current church in session on login
    default_church = resource.church || resource.approved_churches.first
    session[:current_church_id] = default_church&.id
    items_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def track_login
    return unless current_church_member

    TelemetryEvent.track("login", member: current_church_member)
  end

  def track_failed_login
    return if current_church_member

    email = params.dig(:church_member, :email)
    member = ChurchMember.find_by(email: email)
    TelemetryEvent.track("login_failed",
      member: member,
      metadata: { email: email }
    )
  end
end
