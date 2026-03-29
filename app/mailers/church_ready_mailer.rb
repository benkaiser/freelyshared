class ChurchReadyMailer < ApplicationMailer
  def notify_member(church, member)
    @church = church
    @member = member
    mail(
      to: member.email,
      subject: "#{church.name} is now active on FreelyShared!"
    )
  end
end
