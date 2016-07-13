class AddPublicToAlbums < ActiveRecord::Migration
  def up
    add_column :albums, :is_public, :boolean
  end
end
