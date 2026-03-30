class NotificationService
  VAPID_SUBJECT = "mailto:notifications@freelyshared.org"

  class << self
    def notify_new_need(need)
      send_to_church(
        need.church,
        :notify_new_needs,
        title: "New Need Posted",
        body: "#{need.church_member.name}: #{need.title}",
        url: "/needs/#{need.id}",
        exclude_member: need.church_member
      )
    end

    def notify_new_service(service)
      send_to_church(
        service.church,
        :notify_new_services,
        title: "New Service Offered",
        body: "#{service.church_member.name}: #{service.title}",
        url: "/services/#{service.id}",
        exclude_member: service.church_member
      )
    end

    def notify_new_item(item)
      send_to_church(
        item.church,
        :notify_new_items,
        title: "New Item Listed",
        body: "#{item.church_member.name}: #{item.title}",
        url: "/items/#{item.id}",
        exclude_member: item.church_member
      )
    end

    def notify_borrow_request(borrow_request)
      owner = borrow_request.item.church_member
      subscriptions = PushSubscription.where(
        church_member: owner,
        notify_borrow_requests: true
      )

      send_push(subscriptions,
        title: "Borrow Request",
        body: "#{borrow_request.requester.name} wants to borrow #{borrow_request.item.title}",
        url: "/items/#{borrow_request.item_id}"
      )
    end

    private

    def send_to_church(church, preference_field, title:, body:, url:, exclude_member: nil)
      subscriptions = PushSubscription
        .joins(:church_member)
        .where(church_members: { church_id: church.id })
        .where(preference_field => true)

      if exclude_member
        subscriptions = subscriptions.where.not(church_member_id: exclude_member.id)
      end

      send_push(subscriptions, title: title, body: body, url: url)
    end

    def send_push(subscriptions, title:, body:, url:)
      return unless vapid_configured?

      subscriptions.find_each do |sub|
        payload = {
          title: title,
          body: body,
          url: url,
          icon: "/icon.png"
        }.to_json

        begin
          WebPush.payload_send(
            message: payload,
            endpoint: sub.endpoint,
            p256dh: sub.p256dh_key,
            auth: sub.auth_key,
            vapid: {
              subject: VAPID_SUBJECT,
              public_key: ENV["VAPID_PUBLIC_KEY"],
              private_key: ENV["VAPID_PRIVATE_KEY"]
            }
          )
          TelemetryEvent.track("push_notification_sent",
            member: sub.church_member,
            metadata: { title: title }
          )
        rescue WebPush::ExpiredSubscription
          sub.destroy
        rescue WebPush::ResponseError => e
          Rails.logger.warn "Push notification failed: #{e.message}"
        end
      end
    end

    def vapid_configured?
      ENV["VAPID_PUBLIC_KEY"].present? && ENV["VAPID_PRIVATE_KEY"].present?
    end
  end
end
