class Album < ActiveRecord::Base
	belongs_to :user

	def full_path
		"#{path}/#{name}"
	end
end
