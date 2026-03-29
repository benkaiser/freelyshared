class ChurchAdminController < ApplicationController
  before_action :authenticate_church_member!
  before_action :require_admin!

  def show
    @church = current_church
    @pending_members = @church.church_members.pending_approval.order(created_at: :desc)
    @all_members = @church.church_members.approved.order(:name)
  end

  def update_settings
    @church = current_church
    @church.update!(require_admin_approval: params[:require_admin_approval] == "1")
    redirect_to church_admin_path, notice: "Church settings updated."
  end

  def approve_member
    member = current_church.church_members.find(params[:member_id])
    member.update!(approval_status: "approved")
    MemberApprovalMailer.approved(member).deliver_later
    member.send(:check_church_ready)
    redirect_to church_admin_path, notice: "#{member.name} has been approved."
  end

  def reject_member
    member = current_church.church_members.find(params[:member_id])
    MemberApprovalMailer.rejected(member).deliver_later
    member.destroy!
    redirect_to church_admin_path, notice: "Member request has been rejected."
  end

  def toggle_admin
    member = current_church.church_members.find(params[:member_id])
    if member == current_church_member
      redirect_to church_admin_path, alert: "You cannot remove your own admin status."
      return
    end
    member.update!(admin: !member.admin?)
    redirect_to church_admin_path, notice: "#{member.name} admin status updated."
  end

  private

  def require_admin!
    unless current_church_member&.admin?
      redirect_to dashboard_path, alert: "You must be a church admin to access this page."
    end
  end
end
