class Superadmin::DashboardController < Superadmin::BaseController
  def show
    @total_churches = Church.count
    @ready_churches = Church.ready.count
    @pending_churches = Church.pending.count
    @archived_churches = Church.archived.count
    @total_members = ChurchMember.count
    @approved_members = ChurchMember.approved.count
    @total_items = Item.count
    @available_items = Item.available.count
    @total_needs = Need.count
    @total_services = ServicesListing.count
    @borrows_completed = BorrowRequest.where(status: "returned").count

    @pending_churches_list = Church.pending.active.includes(:church_members).order(created_at: :desc).limit(10)
    @recent_members = ChurchMember.includes(:church).order(created_at: :desc).limit(15)
    @recent_items = Item.includes(:church_member, :church).order(created_at: :desc).limit(10)
    @recent_needs = Need.includes(:church_member, :church).order(created_at: :desc).limit(10)
  end
end
