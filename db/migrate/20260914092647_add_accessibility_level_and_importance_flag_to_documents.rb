class AddAccessibilityLevelAndImportanceFlagToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :accessibility_level, :integer
    add_column :documents, :importance_flag, :integer
  end
end
