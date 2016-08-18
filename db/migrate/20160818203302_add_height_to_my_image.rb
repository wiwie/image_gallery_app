class AddHeightToMyImage < ActiveRecord::Migration
  def up
    add_column :my_images, :height, :integer
  end
end
