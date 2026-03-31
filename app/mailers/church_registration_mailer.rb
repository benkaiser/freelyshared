class ChurchRegistrationMailer < ApplicationMailer
  def welcome_registrant(member, church)
    @member = member
    @church = church
    @join_url = church_url(church)
    @qr_url = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=#{CGI.escape(@join_url)}&color=0d6efd"

    mail(
      to: member.email,
      subject: "Welcome to FreelyShared! Share #{church.name}'s sign-up link"
    )
  end
end
