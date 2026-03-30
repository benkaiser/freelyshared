class ChurchAdminController < ApplicationController
  before_action :authenticate_church_member!
  before_action :require_admin!

  def show
    @church = current_church
    @pending_memberships = @church.church_memberships.pending_approval.includes(:church_member).order(created_at: :desc)
    @approved_memberships = @church.church_memberships.approved.includes(:church_member).order("church_members.name")
  end

  def update_settings
    @church = current_church
    attrs = { require_admin_approval: params[:require_admin_approval] == "1" }
    attrs[:name] = params[:church_name] if params[:church_name].present?
    attrs[:location_name] = params[:church_location_name] if params[:church_location_name].present?
    attrs[:latitude] = params[:church_latitude] if params[:church_latitude].present?
    attrs[:longitude] = params[:church_longitude] if params[:church_longitude].present?
    @church.update!(attrs)
    redirect_to church_admin_path, notice: "Church settings updated."
  end

  def approve_member
    membership = current_church.church_memberships.find_by!(church_member_id: params[:member_id])
    membership.update!(approval_status: "approved")
    MemberApprovalMailer.approved(membership.church_member).deliver_later
    redirect_to church_admin_path, notice: "#{membership.church_member.name} has been approved."
  end

  def reject_member
    membership = current_church.church_memberships.find_by!(church_member_id: params[:member_id])
    MemberApprovalMailer.rejected(membership.church_member).deliver_later
    membership.destroy!
    redirect_to church_admin_path, notice: "Member request has been rejected."
  end

  def toggle_admin
    membership = current_church.church_memberships.find_by!(church_member_id: params[:member_id])
    if membership.church_member == current_church_member
      redirect_to church_admin_path, alert: "You cannot remove your own admin status."
      return
    end
    membership.update!(admin: !membership.admin?)
    redirect_to church_admin_path, notice: "#{membership.church_member.name} admin status updated."
  end

  private

  def require_admin!
    unless current_church_member&.admin_of?(current_church)
      redirect_to dashboard_path, alert: "You must be a church admin to access this page."
    end
  end
end
