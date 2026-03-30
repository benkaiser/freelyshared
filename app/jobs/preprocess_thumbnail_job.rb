# Eagerly generates the thumbnail variant for a photo so browse pages
# don't have to wait for lazy processing on the first request.
class PreprocessThumbnailJob < ApplicationJob
  queue_as :default

  def perform(model_class, model_id)
    record = model_class.constantize.find_by(id: model_id)
    return unless record&.photo&.attached?

    StorageService.variant(record.photo, :thumbnail, processed: true)
  end
end
