class NeedsController < ApplicationController
  before_action :authenticate_church_member!
  before_action :set_need, only: [ :show, :edit, :update, :destroy, :fulfill, :reopen ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy, :fulfill, :reopen ]

  def index
    @needs = current_church.needs.open_needs.includes(:church_member).order(created_at: :desc)
  end

  def show
  end

  def new
    @need = current_church_member.needs.build
  end

  def create
    @need = current_church_member.needs.build(need_params)
    @need.church = current_church

    if @need.save
      NotificationService.notify_new_need(@need)
      redirect_to needs_path, notice: "Need posted! Your church community will see it."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @need.update(need_params)
      redirect_to @need, notice: "Need updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @need.destroy
    redirect_to needs_path, notice: "Need removed."
  end

  def fulfill
    @need.fulfill!
    redirect_to @need, notice: "Marked as fulfilled!"
  end

  def reopen
    @need.reopen!
    redirect_to @need, notice: "Need reopened."
  end

  private

  def set_need
    @need = current_church.needs.find(params[:id])
  end

  def authorize_owner!
    unless @need.owner?(current_church_member)
      redirect_to needs_path, alert: "You can only manage your own needs."
    end
  end

  def need_params
    params.require(:need).permit(:title, :description, :contact_info)
  end
end
