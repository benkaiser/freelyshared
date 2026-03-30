class Superadmin::UsersController < Superadmin::BaseController
  skip_before_action :require_superadmin!, only: :stop_impersonating
  before_action :require_impersonating!, only: :stop_impersonating
  def index
    @users = ChurchMember.includes(:church)
    @users = @users.where("LOWER(email) LIKE :q OR LOWER(name) LIKE :q", q: "%#{params[:q].downcase}%") if params[:q].present?
    @users = @users.order(:name)
  end

  def show
    @user = ChurchMember.find(params[:id])
    @items = @user.items.order(created_at: :desc)
    @services = @user.services_listings.order(created_at: :desc)
    @needs = @user.needs.order(created_at: :desc)
    @borrow_requests = @user.borrow_requests.includes(:item).order(created_at: :desc)
  end

  def suspend
    user = ChurchMember.find(params[:id])
    user.update!(suspended: true, suspended_at: Time.current)
    log_moderation("suspend_user", user, reason: params[:reason])
    redirect_to superadmin_user_path(user), notice: "#{user.name} has been suspended."
  end

  def unsuspend
    user = ChurchMember.find(params[:id])
    user.update!(suspended: false, suspended_at: nil)
    log_moderation("unsuspend_user", user)
    redirect_to superadmin_user_path(user), notice: "#{user.name} has been unsuspended."
  end

  def destroy
    user = ChurchMember.find(params[:id])
    name = user.name
    log_moderation("delete_user", user, reason: params[:reason])
    user.destroy!
    redirect_to superadmin_users_path, notice: "#{name} has been deleted."
  end

  def impersonate
    user = ChurchMember.find(params[:id])
    session[:superadmin_id] = current_church_member.id
    sign_in(:church_member, user)
    redirect_to items_path, notice: "You are now impersonating #{user.name}."
  end

  def stop_impersonating
    superadmin = ChurchMember.find(session[:superadmin_id])
    session.delete(:superadmin_id)
    sign_in(:church_member, superadmin)
    redirect_to superadmin_root_path, notice: "Stopped impersonating."
  end

  private

  def require_impersonating!
    raise ActionController::RoutingError, "Not Found" unless session[:superadmin_id].present?
  end
end
