class ChurchMember < ApplicationRecord
  belongs_to :church

  validates :name, presence: true, length: { minimum: 1, maximum: 200 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true

  before_create :generate_verification_token

  after_create :check_church_ready

  private

  def generate_verification_token
    self.verification_token = SecureRandom.urlsafe_base64(32)
  end

  def check_church_ready
    church.check_ready!
  end
end
