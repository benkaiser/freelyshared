class NotificationSettingsController < ApplicationController
  before_action :authenticate_church_member!

  def show
    @subscriptions = current_church_member.push_subscriptions
  end

  def update
    subscription = current_church_member.push_subscriptions.find_by(id: params[:subscription_id])
    if subscription
      subscription.update(notification_params)
      redirect_to notification_settings_path, notice: "Notification preferences updated!"
    else
      redirect_to notification_settings_path, alert: "No push subscription found. Please enable notifications first."
    end
  end

  private

  def notification_params
    params.permit(:notify_new_needs, :notify_new_services, :notify_new_items, :notify_borrow_requests)
  end
end
