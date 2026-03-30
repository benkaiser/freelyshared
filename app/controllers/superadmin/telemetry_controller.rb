class Superadmin::TelemetryController < Superadmin::BaseController
  def show
    @days = (params[:days] || 30).to_i
    @logins = TelemetryEvent.daily_counts("login", days: @days)
    @login_failures = TelemetryEvent.daily_counts("login_failed", days: @days)
    @page_views = TelemetryEvent.daily_counts("page_view", days: @days)
    @password_resets = TelemetryEvent.daily_counts("password_reset_requested", days: @days)
    @emails_sent = TelemetryEvent.daily_counts("email_sent", days: @days)
    @push_sent = TelemetryEvent.daily_counts("push_notification_sent", days: @days)

    @total_logins = TelemetryEvent.of_type("login").since(@days.days.ago).count
    @total_page_views = TelemetryEvent.of_type("page_view").since(@days.days.ago).count
    @active_users = TelemetryEvent.of_type("login").since(@days.days.ago).distinct.count(:church_member_id)

    # Per-church engagement
    @church_engagement = Church.ready.active
      .left_joins(:church_members)
      .select(
        "churches.id, churches.name",
        "COUNT(DISTINCT church_members.id) as member_count"
      )
      .group("churches.id, churches.name")
      .order("member_count DESC")
      .limit(20)

    # Page view breakdown by section
    @page_sections = TelemetryEvent.of_type("page_view")
      .since(@days.days.ago)
      .group("metadata->>'section'")
      .count
      .reject { |k, _| k.nil? }
      .sort_by { |_, v| -v }

    # Home page views
    @home_views = TelemetryEvent.of_type("page_view")
      .since(@days.days.ago)
      .where("metadata->>'section' = ?", "home")
      .count
  end
end
