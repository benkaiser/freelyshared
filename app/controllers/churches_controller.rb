class ChurchesController < ApplicationController
  def search
    if params[:q].present? && params[:q].length >= 2
      @churches = Church.search_by_name(params[:q]).limit(10)
      render json: @churches.map { |c|
        {
          id: c.id,
          name: c.name,
          location_name: c.location_name,
          status: c.status,
          member_count: c.member_count,
          members_needed: c.members_needed
        }
      }
    else
      render json: []
    end
  end

  def show
    @church = Church.find(params[:id])
    @member = ChurchMember.new
  end

  def new
    @church = Church.new
  end

  def create
    @church = Church.new(church_params)
    @church.status = "pending"

    Church.transaction do
      if @church.save
        # Add registrant as first member
        member = @church.church_members.create!(
          name: params[:registrant_name],
          email: params[:registrant_email],
          is_registrant: true
        )

        # Add initial members if provided
        added_count = 1
        if params[:members].present?
          params[:members].each do |m|
            next if m[:name].blank? || m[:email].blank?
            @church.church_members.create!(
              name: m[:name],
              email: m[:email]
            )
            added_count += 1
          end
        end

        redirect_to thankyou_church_path(@church)
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(", ")
    render :new, status: :unprocessable_entity
  end

  def join
    @church = Church.find(params[:id])
    @member = @church.church_members.new(member_params)

    if @member.save
      redirect_to thankyou_church_path(@church)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def thankyou
    @church = Church.find(params[:id])
  end

  private

  def church_params
    params.require(:church).permit(:name, :location_name, :latitude, :longitude, :country_code, :state_code, :postcode)
  end

  def member_params
    params.require(:church_member).permit(:name, :email)
  end
end
