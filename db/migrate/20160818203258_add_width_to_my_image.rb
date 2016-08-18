class AddWidthToMyImage < ActiveRecord::Migration
  def up
    add_column :my_images, :width, :integer
  end
end
