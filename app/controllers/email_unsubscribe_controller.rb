class EmailUnsubscribeController < ApplicationController
  def show
    @member = find_member_from_token
    @category = params[:category]
    @error = "This unsubscribe link has expired or is invalid." if @member.nil?
  end

  def update
    @member = find_member_from_token
    @category = params[:category]

    if @member.nil?
      redirect_to root_path, alert: "This unsubscribe link has expired or is invalid."
      return
    end

    if @category == "all"
      @member.update!(
        email_notify_new_needs: false,
        email_notify_new_items: false,
        email_notify_new_services: false,
        email_notify_church_activation: false
      )
    else
      column = "email_notify_#{@category}"
      if @member.has_attribute?(column)
        @member.update!(column => false)
      end
    end

    @success = true
    render :show
  end

  private

  def find_member_from_token
    return nil unless params[:token].present? && params[:category].present?
    ChurchMember.find_by_unsubscribe_token(params[:token], params[:category])
  end
end
