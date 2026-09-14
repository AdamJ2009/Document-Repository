class AddFolderToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_reference :documents, :folder, null: true, foreign_key: true
  end
end
