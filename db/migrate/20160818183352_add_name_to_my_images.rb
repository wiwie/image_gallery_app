class AddNameToMyImages < ActiveRecord::Migration
  def up
    add_column :my_images, :name, :string
  end
end
