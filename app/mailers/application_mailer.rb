class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "FreelyShared <contact@freelyshared.org>")
  layout "mailer"

  after_deliver :track_email_sent

  private

  def set_unsubscribe_headers(member, category)
    @unsubscribe_url = email_unsubscribe_url(
      token: member.email_unsubscribe_token(category),
      category: category
    )
    @manage_preferences_url = notification_settings_url

    # RFC 8058 List-Unsubscribe header for email clients (Gmail one-click)
    headers["List-Unsubscribe"] = "<#{@unsubscribe_url}>"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
  end

  def track_email_sent
    TelemetryEvent.track("email_sent",
      metadata: { mailer: self.class.name, action: action_name, to: message.to&.first }
    )
  end
end
