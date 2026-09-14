class CreateDocumentVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :document_versions do |t|
      t.references :document, null: false, foreign_key: true
      t.text :diff
      t.text :content_snapshot
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
