class NeedNotificationMailer < ApplicationMailer
  def new_need_posted(member, need, church)
    @member = member
    @need = need
    @church = church
    set_unsubscribe_headers(member, "new_needs")

    mail(
      to: member.email,
      subject: "New need posted in #{church.name}: #{need.title}"
    )
  end
end
