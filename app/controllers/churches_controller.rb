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
        if church_member_signed_in?
          # Signed-in user registering a new church — create membership only
          @church.church_memberships.create!(
            church_member: current_church_member,
            admin: params[:registrant_admin] == "1",
            approval_status: "approved",
            is_registrant: true,
            joined_at: Time.current
          )
          session[:current_church_id] = @church.id
          redirect_to thankyou_church_path(@church)
        else
          # New user registering a church — create ChurchMember + membership
          password = params[:registrant_password]
          registrant_admin = params[:registrant_admin] == "1"
          member = ChurchMember.create!(
            name: params[:registrant_name],
            email: params[:registrant_email],
            password: password,
            password_confirmation: password,
            church: @church
          )
          @church.church_memberships.create!(
            church_member: member,
            admin: registrant_admin,
            approval_status: "approved",
            is_registrant: true,
            joined_at: Time.current
          )

          # Add initial members if provided (they get invited, no password yet)
          if params[:members].present?
            params[:members].each do |m|
              next if m[:name].blank? || m[:email].blank?
              temp_password = SecureRandom.hex(16)
              initial_member = ChurchMember.create!(
                name: m[:name],
                email: m[:email],
                password: temp_password,
                password_confirmation: temp_password,
                church: @church
              )
              @church.church_memberships.create!(
                church_member: initial_member,
                admin: m[:admin] == "1",
                approval_status: "approved",
                joined_at: Time.current
              )
            end
          end

          # Sign in the registrant
          sign_in(member)
          session[:current_church_id] = @church.id
          redirect_to thankyou_church_path(@church)
        end
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

    if church_member_signed_in?
      # Signed-in user joining another church — create membership only
      if current_church_member.membership_for(@church)
        redirect_to church_path(@church), alert: "You are already a member of this church."
        return
      end

      approval = @church.require_admin_approval? ? "pending" : "approved"
      @church.church_memberships.create!(
        church_member: current_church_member,
        approval_status: approval,
        joined_at: Time.current
      )

      if @church.require_admin_approval?
        MemberApprovalMailer.notify_admins_for_church(@church, current_church_member).deliver_later
        redirect_to pending_approval_church_path(@church)
      else
        session[:current_church_id] = @church.id
        redirect_to thankyou_church_path(@church)
      end
    else
      # New user joining — create ChurchMember + membership
      @member = ChurchMember.new(member_params)
      @member.church = @church

      approval = @church.require_admin_approval? ? "pending" : "approved"

      ChurchMember.transaction do
        if @member.save
          @church.church_memberships.create!(
            church_member: @member,
            approval_status: approval,
            joined_at: Time.current
          )

          if @church.require_admin_approval?
            MemberApprovalMailer.notify_admins(@member).deliver_later
            redirect_to pending_approval_church_path(@church)
          else
            sign_in(@member)
            session[:current_church_id] = @church.id
            redirect_to thankyou_church_path(@church)
          end
        else
          render :show, status: :unprocessable_entity
        end
      end
    end
  end

  def thankyou
    @church = Church.find(params[:id])
  end

  def pending_approval
    @church = Church.find(params[:id])
  end

  private

  def church_params
    params.require(:church).permit(:name, :location_name, :latitude, :longitude, :country_code, :state_code, :postcode)
  end

  def member_params
    params.require(:church_member).permit(:name, :email, :password, :password_confirmation)
  end
end
