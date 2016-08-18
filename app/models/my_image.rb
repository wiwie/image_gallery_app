class MyImage < ActiveRecord::Base
	belongs_to :album
	belongs_to :my_image

	def full_path
		File.join(self.album.full_path,self.name)
	end
end
