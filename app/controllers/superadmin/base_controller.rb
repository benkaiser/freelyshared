class Superadmin::BaseController < ApplicationController
  before_action :authenticate_church_member!
  before_action :require_superadmin!

  layout "superadmin"

  private

  def require_superadmin!
    # Return 404 to hide existence of superadmin routes
    raise ActionController::RoutingError, "Not Found" unless current_church_member&.superadmin?
  end

  def log_moderation(action_type, target, reason: nil, church: nil)
    ModerationAction.create!(
      actor: current_church_member,
      action_type: action_type,
      target_type: target.class.name,
      target_id: target.id,
      reason: reason,
      church: church || (target.respond_to?(:church) ? target.church : nil)
    )
  end

  # Impersonation support
  helper_method :impersonating?

  def impersonating?
    session[:superadmin_id].present?
  end
end
