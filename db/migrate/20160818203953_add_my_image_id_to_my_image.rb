class AddMyImageIdToMyImage < ActiveRecord::Migration
  def up
    add_column :my_images, :image_id, :integer
  end
end
