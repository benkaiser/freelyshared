# Facade for file storage operations.
#
# Wraps ActiveStorage to provide a consistent interface regardless of backend
# (Azure Blob, S3, local disk). If the storage backend changes in the future,
# only this service and config/storage.yml need updating — the rest of the app
# talks through this facade.
#
# Usage:
#   StorageService.url_for(item.photo)
#   StorageService.url_for(item.photo, variant: :thumbnail)
#   StorageService.cloud_storage?
#   StorageService.backend
#
class StorageService
  # Variant presets shared across the app. Add new presets here rather than
  # scattering resize options through models/views.
  VARIANT_PRESETS = {
    thumbnail: { resize_to_fill: [ 300, 300 ] },
    medium:    { resize_to_limit: [ 600, 600 ] },
    large:     { resize_to_limit: [ 1200, 1200 ] }
  }.freeze

  # Maximum file sizes by content type category
  MAX_FILE_SIZES = {
    image: 10.megabytes
  }.freeze

  ALLOWED_IMAGE_TYPES = %w[
    image/jpeg
    image/png
    image/gif
    image/webp
  ].freeze

  class << self
    # Returns a processed variant for an attachment using a named preset.
    #
    #   StorageService.variant(item.photo, :thumbnail)
    #   StorageService.variant(item.photo, :thumbnail, processed: true)
    #
    def variant(attachment, preset_name, processed: false)
      return nil unless attachment&.attached?

      transformations = VARIANT_PRESETS.fetch(preset_name) do
        raise ArgumentError, "Unknown variant preset: #{preset_name}. Available: #{VARIANT_PRESETS.keys.join(', ')}"
      end

      v = attachment.variant(transformations)
      processed ? v.processed : v
    end

    # Returns a URL suitable for use in views.
    #
    # For cloud backends (Azure/S3), returns a direct URL to the blob.
    # For disk storage, returns a Rails-routed URL.
    #
    #   StorageService.url_for(item.photo)
    #   StorageService.url_for(item.photo, variant: :thumbnail)
    #
    def url_for(attachment, variant: nil)
      return nil unless attachment&.attached?

      blob_or_variant = if variant
        self.variant(attachment, variant)
      else
        attachment
      end

      Rails.application.routes.url_helpers.url_for(blob_or_variant)
    rescue ArgumentError
      # Fallback if routes aren't available (e.g., in console without request)
      nil
    end

    # Validates an uploadable file before attaching it.
    # Returns an array of error messages (empty if valid).
    #
    #   errors = StorageService.validate_upload(params[:photo], type: :image)
    #
    def validate_upload(file, type: :image)
      errors = []
      return errors if file.blank?

      if type == :image
        unless ALLOWED_IMAGE_TYPES.include?(file.content_type)
          errors << "must be a JPEG, PNG, GIF, or WebP image"
        end

        file_size = file.respond_to?(:byte_size) ? file.byte_size : file.size
        if file_size > MAX_FILE_SIZES[:image]
          errors << "must be smaller than #{MAX_FILE_SIZES[:image] / 1.megabyte}MB"
        end
      end

      errors
    end

    # Returns the symbolic name of the current storage backend.
    #
    #   StorageService.backend  # => :azure, :amazon, or :local
    #
    def backend
      Rails.configuration.active_storage.service
    end

    # True when using a cloud storage provider (Azure or S3).
    #
    #   if StorageService.cloud_storage?
    #     # direct URLs are available
    #   end
    #
    def cloud_storage?
      backend.in?(%i[azure amazon])
    end

    # True when using Azure Blob Storage.
    def azure?
      backend == :azure
    end

    # True when using Amazon S3.
    def s3?
      backend == :amazon
    end

    # True when using local disk storage (development default).
    def local?
      backend == :local
    end

    # Returns a summary of the current storage configuration.
    # Useful for health checks and admin dashboards.
    def status
      {
        backend: backend,
        cloud: cloud_storage?,
        service_class: ActiveStorage::Blob.service.class.name
      }
    end
  end
end
