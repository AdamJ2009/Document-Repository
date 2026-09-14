class CreateArchives < ActiveRecord::Migration[8.1]
  def change
    create_table :archives do |t|
      t.string :title

      t.timestamps
    end
  end
end
