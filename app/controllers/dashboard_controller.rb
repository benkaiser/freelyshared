class DashboardController < ApplicationController
  before_action :authenticate_church_member!

  def index
    redirect_to items_path
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
