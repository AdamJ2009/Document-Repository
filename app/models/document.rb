class Document < ApplicationRecord
  has_one_attached :file

  validate :acceptable_file

  private

  def acceptable_file
    return unless file.attached?

    # Size check (e.g., max 10MB)
    if file.blob.byte_size > 10.megabytes
      errors.add(:file, "is too big (max 10MB)")
    end

    # Extension/content-type check
    acceptable_types = ["text/plain", "application/rtf", "image/png"]
    unless acceptable_types.include?(file.content_type)
      errors.add(:file, "must be a .txt, .rtf, or .png")
    end
  end
end