class Church < ApplicationRecord
  has_many :church_members, dependent: :destroy
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

  scope :search_by_name, ->(query) {
    where("LOWER(name) LIKE ?", "%#{query.downcase}%")
  }

  scope :within_radius, ->(lat, lng, radius_km = 50) {
    where(
      "6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))) <= ?",
      lat, lng, lat, radius_km
    )
  }

  def member_count
    church_members.approved.count
  end

  def members_needed
    [5 - member_count, 0].max
  end

  def admins
    church_members.approved.admins
  end

  def check_ready!
    if member_count >= 5 && status == "pending"
      update!(status: "ready", ready_at: Time.current)
      church_members.approved.each do |member|
        ChurchReadyMailer.notify_member(self, member).deliver_later
      end
    end
  end
end
