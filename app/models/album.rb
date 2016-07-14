class Album < ActiveRecord::Base
	belongs_to :user
	belongs_to :album

	def path
		tmp_album = self.album
		res = ""
		while tmp_album != nil
			res = tmp_album.name + "/" + res
			tmp_album = tmp_album.album
		end
		res
	end

	def full_path
		"#{path}#{name}"
	end
end
