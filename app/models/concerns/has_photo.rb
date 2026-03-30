# Shared concern for models that have a photo attachment.
#
# Centralises variant definitions and validation so every model with a photo
# behaves the same way and goes through the StorageService facade.
#
# Usage:
#   class Item < ApplicationRecord
#     include HasPhoto
#   end
#
#   item.photo_thumbnail   # => variant via StorageService
#   item.photo_medium      # => variant via StorageService
#   item.photo_url         # => URL via StorageService
#   item.photo_url(:thumbnail)
#
module HasPhoto
  extend ActiveSupport::Concern

  included do
    has_one_attached :photo

    validate :validate_photo_file
  end

  def photo_thumbnail
    StorageService.variant(photo, :thumbnail)
  end

  def photo_medium
    StorageService.variant(photo, :medium)
  end

  def photo_large
    StorageService.variant(photo, :large)
  end

  # Returns a URL for the photo, optionally for a specific variant.
  #
  #   item.photo_url              # original
  #   item.photo_url(:thumbnail)  # 300x300
  #
  def photo_url(variant_name = nil)
    StorageService.url_for(photo, variant: variant_name)
  end

  private

  def validate_photo_file
    return unless photo.attached?
    return unless photo.blob.persisted? # skip validation for already-saved blobs

    errors_list = StorageService.validate_upload(photo.blob, type: :image)
    errors_list.each do |msg|
      errors.add(:photo, msg)
    end
  end
end
