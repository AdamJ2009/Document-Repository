class Archive < ApplicationRecord
  belongs_to :folder, optional: true
  has_one_attached :file

  def restore!
    Document.transaction do
      Document.create!(
        title: title,
        file: file.blob,
        folder: folder
      )
      destroy!
    end
  end
end