class PushSubscription < ApplicationRecord
  belongs_to :church_member

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh_key, presence: true
  validates :auth_key, presence: true
end
