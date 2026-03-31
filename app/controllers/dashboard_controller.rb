class DashboardController < ApplicationController
  before_action :authenticate_church_member!

  def index
    @member = current_church_member
    @church = current_church

    # Pending borrow requests on my items
    @incoming_pending = BorrowRequest.pending
      .joins(:item)
      .includes(:requester, item: :church_member)
      .where(items: { church_member_id: @member.id })
      .order(created_at: :desc)

    # Recent items from the church (limit 8 for the preview row)
    @recent_items = @church.visible_items
      .includes(:church_member, photo_attachment: :blob)
      .order(created_at: :desc)
      .limit(8)

    # Open needs
    @recent_needs = @church.visible_needs
      .open_needs
      .includes(:church_member)
      .order(created_at: :desc)
      .limit(5)

    # Services
    @recent_services = @church.visible_services_listings
      .includes(:church_member)
      .order(created_at: :desc)
      .limit(6)
  end

  def my_listings
    @items = current_church_member.items.order(created_at: :desc)
    @services = current_church_member.services_listings.order(created_at: :desc)
    @needs = current_church_member.needs.order(created_at: :desc)
  end

  def my_borrow_requests
    @incoming_requests = BorrowRequest.joins(:item)
      .where(items: { church_member_id: current_church_member.id })
      .order(created_at: :desc)
    @outgoing_requests = current_church_member.borrow_requests.order(created_at: :desc)
  end
end
