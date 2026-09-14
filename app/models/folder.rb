class Folder < ApplicationRecord
  has_many :documents, dependent: :nullify
  has_many :archives, dependent: :nullify

  enum :status, { active: 0, archived: 1 }, default: :active

  validates :name, presence: true, uniqueness: { scope: :status }

  scope :active, -> { where(status: :active) }
  scope :archived, -> { where(status: :archived) }

  def archive!
    transaction do
      update!(status: :archived)

      # Destroying the document automatically triggers Document's before_destroy :archive_document callback
      documents.find_each do |doc|
        doc.destroy!
      end
    end
  end

  def restore!
    transaction do
      update!(status: :active)

      # Restore every archive record bound to this folder
      archives.find_each(&:restore!)
    end
  end
end