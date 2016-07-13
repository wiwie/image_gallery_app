class AddPathToAlbums < ActiveRecord::Migration
  def up
    add_column :albums, :path, :string
  end
end
