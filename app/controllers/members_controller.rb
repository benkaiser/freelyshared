class MembersController < ApplicationController
  before_action :authenticate_church_member!

  def index
    @members = current_church.church_members
      .approved
      .where(show_in_directory: true)
      .order(:name)
  end

  def show
    @member = current_church.church_members.approved.find(params[:id])
    @items = @member.items.available.order(created_at: :desc)
    @services = @member.services_listings.order(created_at: :desc)
  end
end
