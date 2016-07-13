class AddUserToAlbums < ActiveRecord::Migration
  def up
    add_column :albums, :user_id, :integer
  end
end
