class CreateUserAlbumPermissions < ActiveRecord::Migration
  def change
    create_table :user_album_permissions do |t|
      t.integer :user_id
      t.integer :album_id
      t.boolean :can_read
      t.boolean :can_edit

      t.timestamps null: false
    end
  end
end
