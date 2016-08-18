class AddAlbumIdToMyImage < ActiveRecord::Migration
  def up
    add_column :my_images, :album_id, :integer
  end
end
