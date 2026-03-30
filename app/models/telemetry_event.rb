class TelemetryEvent < ApplicationRecord
  belongs_to :church, optional: true
  belongs_to :church_member, optional: true

  validates :event_type, presence: true

  EVENT_TYPES = %w[
    login login_failed password_reset_requested password_reset_completed
    email_sent push_notification_sent
    page_view
  ].freeze

  scope :recent, -> { order(created_at: :desc) }
  scope :of_type, ->(type) { where(event_type: type) }
  scope :since, ->(time) { where("created_at >= ?", time) }
  scope :for_church, ->(church) { where(church: church) }

  class << self
    def track(event_type, church: nil, member: nil, metadata: {})
      create!(
        event_type: event_type,
        church: church || member&.church,
        church_member: member,
        metadata: metadata,
        created_at: Time.current
      )
    rescue => e
      Rails.logger.warn "Telemetry tracking failed: #{e.message}"
    end

    def daily_counts(event_type, days: 30)
      of_type(event_type)
        .since(days.days.ago)
        .group("DATE(created_at)")
        .count
        .transform_keys { |k| k.to_date }
    end
  end
end
