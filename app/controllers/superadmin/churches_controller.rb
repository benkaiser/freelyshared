class Superadmin::ChurchesController < Superadmin::BaseController
  def index
    @churches = Church.includes(:church_memberships)
    @churches = @churches.where("LOWER(name) LIKE ?", "%#{params[:q].downcase}%") if params[:q].present?
    @churches = @churches.order(:name)
  end

  def show
    @church = Church.find(params[:id])
    @memberships = @church.church_memberships.approved.includes(:church_member).order("church_members.name")
    @pending_memberships = @church.church_memberships.pending_approval.includes(:church_member).order(created_at: :desc)
    @items_count = @church.visible_items.count
    @services_count = @church.visible_services_listings.count
    @needs_count = @church.visible_needs.count
    @borrows_completed = BorrowRequest.joins(:item)
      .where(item_id: @church.visible_items.select(:id), status: "returned").count
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
    attrs = { require_admin_approval: params[:require_admin_approval] == "1" }
    attrs[:name] = params[:church_name] if params[:church_name].present?
    attrs[:location_name] = params[:church_location_name] if params[:church_location_name].present?
    attrs[:latitude] = params[:church_latitude] if params[:church_latitude].present?
    attrs[:longitude] = params[:church_longitude] if params[:church_longitude].present?
    church.update!(attrs)
    redirect_to superadmin_church_path(church), notice: "Settings updated for #{church.name}."
  end

  def promote_admin
    church = Church.find(params[:id])
    membership = church.church_memberships.find_by!(church_member_id: params[:member_id])
    membership.update!(admin: true)
    log_moderation("promote_admin", membership.church_member, church: church)
    redirect_to superadmin_church_path(church), notice: "#{membership.church_member.name} is now an admin."
  end

  def demote_admin
    church = Church.find(params[:id])
    membership = church.church_memberships.find_by!(church_member_id: params[:member_id])
    membership.update!(admin: false)
    log_moderation("demote_admin", membership.church_member, church: church)
    redirect_to superadmin_church_path(church), notice: "#{membership.church_member.name} is no longer an admin."
  end

  def approve_member
    church = Church.find(params[:id])
    membership = church.church_memberships.find_by!(church_member_id: params[:member_id])
    membership.update!(approval_status: "approved")
    MemberApprovalMailer.approved(membership.church_member).deliver_later
    log_moderation("approve_member", membership.church_member, church: church)
    redirect_to superadmin_church_path(church), notice: "#{membership.church_member.name} has been approved."
  end
end
