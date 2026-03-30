class ChurchMembershipsController < ApplicationController
  before_action :authenticate_church_member!

  def index
    @approved_memberships = current_church_member.church_memberships.approved.includes(:church).order("churches.name")
    @pending_memberships = current_church_member.church_memberships.pending_approval.includes(:church).order(created_at: :desc)
  end

  def destroy
    membership = current_church_member.church_memberships.find(params[:id])
    church_name = membership.church.name
    remaining = current_church_member.church_memberships.approved.where.not(id: membership.id)

    membership.destroy!

    if remaining.any?
      # Switch to another church if leaving the current one
      if session[:current_church_id].to_s == membership.church_id.to_s
        next_church = remaining.first.church
        session[:current_church_id] = next_church.id
      end
      redirect_to church_memberships_path, notice: "You have left #{church_name}."
    else
      # Last church — sign out
      sign_out(current_church_member)
      redirect_to root_path, notice: "You have left #{church_name}. You are no longer a member of any church."
    end
  end
end
