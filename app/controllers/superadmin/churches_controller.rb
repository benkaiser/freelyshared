class Superadmin::ChurchesController < Superadmin::BaseController
  def index
    @churches = Church.includes(:church_members)
    @churches = @churches.where("LOWER(name) LIKE ?", "%#{params[:q].downcase}%") if params[:q].present?
    @churches = @churches.order(:name)
  end

  def show
    @church = Church.find(params[:id])
    @members = @church.church_members.order(:name)
    @pending_members = @church.church_members.pending_approval.order(created_at: :desc)
    @items_count = @church.items.count
    @services_count = @church.services_listings.count
    @needs_count = @church.needs.count
    @borrows_completed = BorrowRequest.joins(:item).where(items: { church_id: @church.id }, status: "returned").count
    @recent_moderation = ModerationAction.for_church(@church).recent.limit(10).includes(:actor)
  end

  def activate
    church = Church.find(params[:id])
    church.update!(status: "ready", ready_at: Time.current)
    log_moderation("activate_church", church)
    redirect_to superadmin_church_path(church), notice: "#{church.name} has been activated."
  end

  def archive
    church = Church.find(params[:id])
    church.update!(archived: true, archived_at: Time.current)
    log_moderation("archive_church", church)
    redirect_to superadmin_church_path(church), notice: "#{church.name} has been archived."
  end

  def unarchive
    church = Church.find(params[:id])
    church.update!(archived: false, archived_at: nil)
    log_moderation("activate_church", church, reason: "Unarchived")
    redirect_to superadmin_church_path(church), notice: "#{church.name} has been unarchived."
  end

  def update_settings
    church = Church.find(params[:id])
    church.update!(require_admin_approval: params[:require_admin_approval] == "1")
    redirect_to superadmin_church_path(church), notice: "Settings updated for #{church.name}."
  end

  def promote_admin
    church = Church.find(params[:id])
    member = church.church_members.find(params[:member_id])
    member.update!(admin: true)
    log_moderation("promote_admin", member, church: church)
    redirect_to superadmin_church_path(church), notice: "#{member.name} is now an admin."
  end

  def demote_admin
    church = Church.find(params[:id])
    member = church.church_members.find(params[:member_id])
    member.update!(admin: false)
    log_moderation("demote_admin", member, church: church)
    redirect_to superadmin_church_path(church), notice: "#{member.name} is no longer an admin."
  end

  def approve_member
    church = Church.find(params[:id])
    member = church.church_members.find(params[:member_id])
    member.update!(approval_status: "approved")
    MemberApprovalMailer.approved(member).deliver_later
    member.send(:check_church_ready)
    log_moderation("approve_member", member, church: church)
    redirect_to superadmin_church_path(church), notice: "#{member.name} has been approved."
  end
end
