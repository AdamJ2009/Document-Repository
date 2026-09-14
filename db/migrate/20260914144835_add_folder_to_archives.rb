class AddFolderToArchives < ActiveRecord::Migration[8.1]
def change
    add_reference :archives, :folder, null: true, foreign_key: true
  end
end
