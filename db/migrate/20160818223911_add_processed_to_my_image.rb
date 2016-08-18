class AddProcessedToMyImage < ActiveRecord::Migration
  def up
    add_column :my_images, :processed, :boolean
  end
end
