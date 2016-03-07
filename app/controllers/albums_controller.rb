require 'fastimage'

class AlbumsController < ApplicationController
	def index
		@root_dir = Rails.application.config.image_folder_path
		if params.has_key?(:path)
			# we do not allow to go out of our directory
			@root_dir = File.join(@root_dir,params[:path]).gsub('..','.')
		end

		puts @root_dir

		@folders = Pathname.new(@root_dir).children.select { |c| c.directory? and c.basename.to_s != '.thumb' }.collect { |p| p.to_s.sub(@root_dir,'') }.sort
		puts @folders
		@files = Pathname.new(@root_dir).children
			.select { |c| c.to_s.downcase.end_with?('jpg') or c.to_s.downcase.end_with?('jpeg') or c.to_s.downcase.end_with?('png') }
			.sort.collect { |p| [p.to_s.gsub(Rails.application.config.image_folder_path, ''), FastImage.size(p.to_s)
] }
	end

	def new
		@album = Album.new
	end

	def create
		newDir = File.join(Rails.application.config.image_folder_path, params[:album][:path],params[:album][:name])
		Dir.mkdir(newDir) unless File.exists?(newDir)
		redirect_to(action: 'index', path: File.join(params[:album][:path],params[:album][:name]))
	end
end
