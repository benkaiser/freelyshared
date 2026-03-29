class PushSubscriptionsController < ApplicationController
  before_action :authenticate_church_member!
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    sub_data = params[:subscription]
    subscription = current_church_member.push_subscriptions.find_or_initialize_by(
      endpoint: sub_data[:endpoint]
    )
    subscription.p256dh_key = sub_data[:keys][:p256dh]
    subscription.auth_key = sub_data[:keys][:auth]

    if subscription.save
      render json: { status: "ok" }, status: :created
    else
      render json: { error: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
