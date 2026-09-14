class Document < ApplicationRecord
  MAX_DIFF_SIZE = 10.megabytes

  has_one_attached :file
  has_many :document_versions, dependent: :destroy

  validate :acceptable_file
  before_destroy :archive_document

  around_update :create_version_diff

  enum :accessibility_level, { public_access: 0, logged_in: 1, admin_only: 2 }, prefix: :access
  enum :importance_flag, { normal: 0, important: 1 }, prefix: :importance

  scope :public_only, -> { where(accessibility_level: :public_access) }
  scope :for_regular_users, -> { where(accessibility_level: [:public_access, :logged_in]) }

  def self.for_user(user)
    base_scope = if user&.admin?
                   all
                 elsif user.present?
                   for_regular_users
                 else
                   public_only
                 end

    base_scope.order(importance_flag: :desc, created_at: :desc)
  end

  private

  def acceptable_file
    return unless file.attached?

    if attachment_changes.key?("file")
      attachable = attachment_changes["file"].attachable

      file_size = case attachable
                  when ActionDispatch::Http::UploadedFile, File, Tempfile
                    attachable.size
                  when ActiveStorage::Blob
                    attachable.byte_size
                  end

      file_type = case attachable
                  when ActionDispatch::Http::UploadedFile
                    attachable.content_type
                  when ActiveStorage::Blob
                    attachable.content_type
                  end
    else
      file_size = file.blob&.byte_size
      file_type = file.blob&.content_type
    end

    if file_size && file_size > MAX_DIFF_SIZE
      errors.add(:file, "is too big (max 10MB)")
    end

    acceptable_types = ["text/plain", "application/rtf", "image/png"]
    if file_type && !acceptable_types.include?(file_type)
      errors.add(:file, "must be a .txt, .rtf, or .png")
    end
  end

  def archive_document
    return unless file.attached?

    Archive.create!(
      title: title,
      file: file.blob
    )
  end

  def create_version_diff
    # 1. Capture state before yield
    old_content = text_content_for_existing_blob
    file_was_changed = attachment_changes.key?("file")

    # Track dirty attribute changes before save
    tracked_changes = {}
    %w[title accessibility_level importance_flag].each do |attr|
      if attribute_changed?(attr)
        tracked_changes[attr] = [attribute_was(attr), send(attr)]
      end
    end

    new_uploaded_file = if file_was_changed
                          read_attachable_text(attachment_changes["file"].attachable)
                        end

    yield # Execute save in database

    # 2. Compile diff output if attributes or file changed
    if file_was_changed || tracked_changes.any?
      diff_parts = []

      # Format attribute metadata changes
      tracked_changes.each do |attr, (old_val, new_val)|
        diff_parts << "Changed #{attr.humanize}: '#{old_val}' → '#{new_val}'"
      end

      # Format file content diff
      if file_was_changed
        new_content = new_uploaded_file || ""
        formatted_old = old_content.blank? ? "" : "#{old_content.chomp}\n"
        formatted_new = new_content.blank? ? "" : "#{new_content.chomp}\n"

        file_diff = Diffy::Diff.new(formatted_old, formatted_new).to_s(:text)
        diff_parts << "\n--- File Changes ---\n#{file_diff}" if file_diff.present?
      end

      document_versions.create!(
        diff: diff_parts.join("\n"),
        content_snapshot: old_content,
        user: Current.user
      )
    end
  end

  def text_content_for_existing_blob
    attachment = file_attachment
    return "" unless attachment&.persisted?

    blob = attachment.blob
    return "" unless blob && readable_text?(blob)

    blob.download.force_encoding("UTF-8").scrub
  rescue ActiveStorage::FileNotFoundError
    ""
  end

  def read_attachable_text(attachable)
    case attachable
    when ActionDispatch::Http::UploadedFile, Tempfile, File
      attachable.rewind if attachable.respond_to?(:rewind)
      content = attachable.read
      attachable.rewind if attachable.respond_to?(:rewind)
      content.to_s.force_encoding("UTF-8").scrub
    when ActiveStorage::Blob
      attachable.download.force_encoding("UTF-8").scrub
    else
      ""
    end
  rescue StandardError
    ""
  end

  def readable_text?(blob)
    blob.byte_size <= MAX_DIFF_SIZE && (blob.content_type.start_with?("text/") || blob.content_type == "application/json")
  end
end