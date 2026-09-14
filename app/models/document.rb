class Document < ApplicationRecord
  has_one_attached :file

  validate :acceptable_file

  before_destroy :archive_document

  # Modern Rails enum syntax (symbol first):
  enum :accessibility_level, { public_access: 0, logged_in: 1, admin_only: 2 }, prefix: :access
  enum :importance_flag, { normal: 0, important: 1 }, prefix: :importance

  # Scope definitions
  scope :public_only, -> { where(accessibility_level: :public_access) }
  scope :for_regular_users, -> { where(accessibility_level: [:public_access, :logged_in]) }

  # Class method filtering replacement
  def self.for_user(user)
    base_scope = if user&.admin?
                   all
                 elsif user.present?
                   for_regular_users
                 else
                   public_only
                 end

    # Sorts important (1) above normal (0), then newest first
    base_scope.order(importance_flag: :desc, created_at: :desc)
  end
  

  private

  def acceptable_file
    return unless file.attached?

    if file.blob.byte_size > 10.megabytes
      errors.add(:file, "is too big (max 10MB)")
    end

    acceptable_types = ["text/plain", "application/rtf", "image/png"]
    unless acceptable_types.include?(file.content_type)
      errors.add(:file, "must be a .txt, .rtf, or .png")
    end
  end

  def archive_document
    Archive.create!(
      title: title,
      file: file.blob
    )
  end
end