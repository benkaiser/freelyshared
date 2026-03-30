class Superadmin::ModerationController < Superadmin::BaseController
  def index
    @actions = ModerationAction.recent.includes(:actor, :church)
    @actions = @actions.for_church(Church.find(params[:church_id])) if params[:church_id].present?
    @actions = @actions.by_type(params[:action_type]) if params[:action_type].present?
    @actions = @actions.where(actor_id: params[:actor_id]) if params[:actor_id].present?
    @actions = @actions.limit(100)
  end

  def remove_item
    item = Item.find(params[:id])
    log_moderation("remove_item", item, reason: params[:reason])
    item.destroy!
    redirect_back fallback_location: superadmin_church_path(item.church), notice: "Item removed."
  end

  def remove_service
    service = ServicesListing.find(params[:id])
    log_moderation("remove_service", service, reason: params[:reason])
    service.destroy!
    redirect_back fallback_location: superadmin_church_path(service.church), notice: "Service removed."
  end

  def remove_need
    need = Need.find(params[:id])
    log_moderation("remove_need", need, reason: params[:reason])
    need.destroy!
    redirect_back fallback_location: superadmin_church_path(need.church), notice: "Need removed."
  end
end
