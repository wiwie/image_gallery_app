class AddAlbumToAlbums < ActiveRecord::Migration
  def up
    add_column :albums, :album_id, :integer
  end
end
