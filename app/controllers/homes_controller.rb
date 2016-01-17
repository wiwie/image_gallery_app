class HomesController < ApplicationController
	def index
		root_dir = Rails.application.config.image_folder_path

		#Dir.chdir(root_dir)
		#puts Dir.glob('**').select {|f| File.directory? f}
		#puts Dir.entries(root_dir).select {|entry| File.directory? File.join(root_dir,entry) and !(entry =='.' || entry == '..') }
		puts Pathname.new(root_dir).children.select { |c| c.directory? }.collect { |p| p.to_s }
	end
end
