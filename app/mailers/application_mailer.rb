class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  after_deliver :track_email_sent

  private

  def track_email_sent
    TelemetryEvent.track("email_sent",
      metadata: { mailer: self.class.name, action: action_name, to: message.to&.first }
    )
  end
end
