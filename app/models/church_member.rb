class ChurchMember < ApplicationRecord
  include HasPhoto

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :church, optional: true

  has_many :church_memberships, dependent: :destroy
  has_many :churches, through: :church_memberships

  has_many :items, dependent: :destroy
  has_many :services_listings, dependent: :destroy
  has_many :needs, dependent: :destroy
  has_many :borrow_requests, foreign_key: :requester_id, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy
  has_many :moderation_actions, foreign_key: :actor_id, dependent: :nullify

  validates :name, presence: true, length: { minimum: 1, maximum: 200 }
  validates :approval_status, inclusion: { in: %w[approved pending rejected] }

  scope :approved, -> { where(approval_status: "approved") }
  scope :pending_approval, -> { where(approval_status: "pending") }
  scope :admins, -> { where(admin: true) }
  scope :superadmins, -> { where(superadmin: true) }
  scope :active, -> { where(suspended: false) }
  scope :suspended, -> { where(suspended: true) }

  before_create :generate_verification_token

  after_create :check_church_ready

  def admin?
    admin
  end

  def superadmin?
    superadmin
  end

  def suspended?
    suspended
  end

  def approved?
    approval_status == "approved"
  end

  def pending_approval?
    approval_status == "pending"
  end

  # Multi-church membership helpers
  def member_of?(church)
    church_memberships.approved.exists?(church_id: church.id)
  end

  def admin_of?(church)
    church_memberships.admins.exists?(church_id: church.id)
  end

  def approved_churches
    churches.merge(ChurchMembership.approved)
  end

  def membership_for(church)
    church_memberships.find_by(church_id: church.id)
  end

  # Stateless unsubscribe tokens via Rails signed_id
  def email_unsubscribe_token(category)
    signed_id(purpose: "unsubscribe_#{category}", expires_in: 90.days)
  end

  def self.find_by_unsubscribe_token(token, category)
    find_signed(token, purpose: "unsubscribe_#{category}")
  end

  # Devise: block suspended members from signing in.
  # Allow login if they have ANY approved membership.
  def active_for_authentication?
    super && !suspended? && (church_memberships.approved.exists? || approved?)
  end

  def inactive_message
    if suspended?
      :suspended
    elsif !church_memberships.approved.exists? && !approved?
      :pending_approval
    else
      super
    end
  end

  # Returns a URL string for the member's avatar.
  # Uses the uploaded photo variant if present, otherwise falls back to Gravatar.
  def avatar_url(size = 80)
    if photo.attached?
      variant_name = size <= 100 ? :thumbnail : :medium
      variant = StorageService.variant(photo, variant_name)
      Rails.application.routes.url_helpers.rails_representation_path(variant.processed, only_path: true)
    else
      gravatar_url(size)
    end
  end

  private

  def gravatar_url(size = 80)
    hash = Digest::MD5.hexdigest(email.downcase.strip)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=mp"
  end

  def generate_verification_token
    self.verification_token = SecureRandom.urlsafe_base64(32)
  end

  def check_church_ready
    church&.check_ready!
  end
end
