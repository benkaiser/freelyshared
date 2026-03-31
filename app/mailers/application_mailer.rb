class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "FreelyShared <contact@freelyshared.org>")
  layout "mailer"

  after_deliver :track_email_sent

  private

  def track_email_sent
    TelemetryEvent.track("email_sent",
      metadata: { mailer: self.class.name, action: action_name, to: message.to&.first }
    )
  end
end
