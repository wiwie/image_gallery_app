class AddNameRotatedToMyImages < ActiveRecord::Migration
  def up
    add_column :my_images, :rotated_name, :string
  end
end
