class GeographicSignup < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 200 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :suburb_name, presence: true, length: { minimum: 1, maximum: 200 }
  validates :latitude, :longitude, presence: true, numericality: true

  scope :verified, -> { where(email_verified: true) }
  scope :within_radius, ->(lat, lng, radius_km = 50) {
    # Haversine formula for geographic distance
    where(
      "6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))) <= ?",
      lat, lng, lat, radius_km
    )
  }

  def nearby_signups(radius_km = 50)
    self.class.verified.within_radius(latitude, longitude, radius_km).where.not(id: id)
  end

  def generate_verification_token
    self.verification_token = SecureRandom.urlsafe_base64(32)
  end

  before_create :generate_verification_token
end
