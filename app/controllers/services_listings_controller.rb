class ServicesListingsController < ApplicationController
  before_action :authenticate_church_member!
  before_action :set_service, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def index
    @services = current_church.services_listings.includes(:church_member).order(created_at: :desc)
  end

  def show
  end

  def new
    @service = current_church_member.services_listings.build
  end

  def create
    @service = current_church_member.services_listings.build(service_params)
    @service.church = current_church

    if @service.save
      NotificationService.notify_new_service(@service)
      redirect_to services_path, notice: "Service listed successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to services_path, notice: "Service updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.destroy
    redirect_to services_path, notice: "Service removed."
  end

  private

  def set_service
    @service = current_church.services_listings.find(params[:id])
  end

  def authorize_owner!
    unless @service.owner?(current_church_member)
      redirect_to services_path, alert: "You can only edit your own services."
    end
  end

  def service_params
    params.require(:services_listing).permit(:title, :description, :contact_preference)
  end
end
