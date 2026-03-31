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

  def invite_member
    @church = current_church
    email = params[:invite_email]&.strip
    name = params[:invite_name]&.strip

    if email.blank? || name.blank?
      redirect_to church_admin_path, alert: "Please provide both a name and email."
      return
    end

    existing = ChurchMember.find_by(email: email)
    if existing
      # Existing user — just create a membership
      if existing.membership_for(@church)
        redirect_to church_admin_path, alert: "#{name} is already a member of this church."
        return
      end
      @church.church_memberships.create!(
        church_member: existing,
        approval_status: "approved",
        joined_at: Time.current
      )
      InvitationMailer.invite_member(existing, @church, invited_by: current_church_member).deliver_later
      redirect_to church_admin_path, notice: "#{name} has been added and notified!"
    else
      # New user — create account + membership
      temp_password = SecureRandom.hex(16)
      member = ChurchMember.create!(
        name: name,
        email: email,
        password: temp_password,
        password_confirmation: temp_password,
        church: @church
      )
      @church.church_memberships.create!(
        church_member: member,
        approval_status: "approved",
        joined_at: Time.current
      )
      InvitationMailer.invite_member(member, @church, invited_by: current_church_member).deliver_later
      redirect_to church_admin_path, notice: "#{name} has been invited and will receive an email to set their password!"
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to church_admin_path, alert: e.record.errors.full_messages.join(", ")
  end

  private

  def require_admin!
    unless current_church_member&.admin_of?(current_church)
      redirect_to dashboard_path, alert: "You must be a church admin to access this page."
    end
  end
end
