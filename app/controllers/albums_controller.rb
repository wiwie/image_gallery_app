require 'fastimage'

class AlbumsController < ApplicationController
	def index
		@root_dir = Rails.application.config.image_folder_path
		if params.has_key?(:path)
			# we do not allow to go out of our directory
			@root_dir = File.join(@root_dir,params[:path]).gsub('..','.')
		end

		puts @root_dir

		@folders = Pathname.new(@root_dir).children.select { |c| c.directory? }.collect { |p| p.to_s.sub(@root_dir,'') }
		puts @folders
		@files = Pathname.new(@root_dir).children
			.select { |c| c.to_s.downcase.end_with?('jpg') or c.to_s.downcase.end_with?('jpeg') or c.to_s.downcase.end_with?('png') }
			.collect { |p| [p.to_s, FastImage.size(p.to_s)
] }
	end
end
