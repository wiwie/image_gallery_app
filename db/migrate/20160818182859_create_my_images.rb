class CreateMyImages < ActiveRecord::Migration
  def up
    create_table :my_images do |t|
    	
      t.timestamps null: false
    end
  end
end
