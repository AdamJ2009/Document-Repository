class BackfillDocumentDefaults < ActiveRecord::Migration[7.0]
  def up
    Document.where(accessibility_level: nil).update_all(accessibility_level: 0)
    Document.where(importance_flag: nil).update_all(importance_flag: 0)
  end

  def down
    # No-op: cannot reverse backfilled default values safely
  end
end