class ChurchSwitcherController < ApplicationController
  before_action :authenticate_church_member!

  def switch
    church = Church.find(params[:church_id])

    if current_church_member.member_of?(church)
      session[:current_church_id] = church.id
      # Clear memoized values
      @current_church = nil
      @current_membership = nil
      redirect_to items_path, notice: "Switched to #{church.name}."
    else
      redirect_to items_path, alert: "You are not a member of that church."
    end
  end
end
