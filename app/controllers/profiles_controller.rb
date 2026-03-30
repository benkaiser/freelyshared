class ProfilesController < ApplicationController
  before_action :authenticate_church_member!

  def show
    @member = current_church_member
    @items = @member.items.order(created_at: :desc)
    @services = @member.services_listings.order(created_at: :desc)
    @needs = @member.needs.order(created_at: :desc)
    @incoming_pending = BorrowRequest.pending
      .joins(:item)
      .includes(:requester, item: :church_member)
      .where(items: { church_member_id: @member.id })
      .order(created_at: :desc)
  end

  def edit
    @member = current_church_member
  end

  def update
    @member = current_church_member
    if @member.update(profile_params)
      redirect_to profile_path, notice: "Profile updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:church_member).permit(:name, :phone, :show_email, :show_in_directory, :photo)
  end
end
