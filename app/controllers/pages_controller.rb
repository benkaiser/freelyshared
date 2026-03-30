class PagesController < ApplicationController
  def home
    # Load a sample church to showcase real data on the landing page
    # Prefer a demo church for showcase, fall back to first ready church
    @showcase_church = Church.ready.active.where(demo: true).first || Church.ready.active.first

    if @showcase_church
      @showcase_items = @showcase_church.visible_items
        .joins(:photo_attachment)
        .includes(:church_member, photo_attachment: :blob)
        .limit(5)

      @showcase_services = @showcase_church.visible_services_listings
        .includes(:church_member)
        .limit(3)

      @showcase_needs = @showcase_church.visible_needs
        .where(status: "open")
        .includes(:church_member)
        .limit(3)

      @showcase_members = @showcase_church.approved_members
        .joins(:photo_attachment)
        .includes(photo_attachment: :blob)
        .limit(5)
    end
  end
end
