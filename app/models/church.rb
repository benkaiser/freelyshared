class Church < ApplicationRecord
  has_many :church_memberships, dependent: :destroy
  has_many :church_members, through: :church_memberships

  # Keep direct associations for legacy/migration support, but primary access is through memberships
  has_many :items, dependent: :destroy
  has_many :services_listings, dependent: :destroy
  has_many :needs, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 300 }
  validates :location_name, presence: true, length: { minimum: 1, maximum: 300 }
  validates :latitude, :longitude, presence: true, numericality: true
  validates :status, presence: true, inclusion: { in: %w[pending ready] }

  scope :ready, -> { where(status: "ready") }
  scope :pending, -> { where(status: "pending") }
  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :not_demo, -> { where(demo: false) }

  scope :search_by_name, ->(query) {
    where("LOWER(name) LIKE ?", "%#{query.downcase}%")
  }

  scope :within_radius, ->(lat, lng, radius_km = 50) {
    where(
      "6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))) <= ?",
      lat, lng, lat, radius_km
    )
  }

  # Returns members who have an approved membership in this church
  def approved_members
    ChurchMember.where(
      id: church_memberships.approved.select(:church_member_id)
    )
  end

  # Returns members with pending membership in this church
  def pending_members
    ChurchMember.where(
      id: church_memberships.pending_approval.select(:church_member_id)
    )
  end

  # Visible items: items owned by any approved member of this church
  def visible_items
    Item.where(church_member_id: church_memberships.approved.select(:church_member_id))
  end

  # Visible needs: needs owned by any approved member of this church
  def visible_needs
    Need.where(church_member_id: church_memberships.approved.select(:church_member_id))
  end

  # Visible services: services owned by any approved member of this church
  def visible_services_listings
    ServicesListing.where(church_member_id: church_memberships.approved.select(:church_member_id))
  end

  def member_count
    church_memberships.approved.count
  end

  def members_needed
    [5 - member_count, 0].max
  end

  def admins
    approved_members.where(
      id: church_memberships.admins.select(:church_member_id)
    )
  end

  def check_ready!
    if member_count >= 5 && status == "pending"
      update!(status: "ready", ready_at: Time.current)
      approved_members.each do |member|
        ChurchReadyMailer.notify_member(self, member).deliver_later
      end
    end
  end

  # Email rate limiting: only send one notification email per type per church per 24 hours
  def can_send_email_notification?(type)
    column = "last_#{type}_email_sent_at"
    last_sent = self[column]
    last_sent.nil? || last_sent < 24.hours.ago
  end

  def record_email_notification_sent!(type)
    update_column("last_#{type}_email_sent_at", Time.current)
  end
end
