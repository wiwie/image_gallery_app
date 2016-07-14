require 'fastimage'

class AlbumsController < ApplicationController
	def index
		redirect_to(action: 'show', id: 1)
	end

	def show
		@album = Album.find(params[:id])
		@root_dir = Rails.application.config.image_folder_path
		puts @root_dir
		puts @album.full_path
		#if params.has_key?(:path)
			# we do not allow to go out of our directory
			@root_dir = File.join(@root_dir,@album.full_path).gsub('..','.')
		#end
		puts @root_dir

		@can_read = false
		@can_write = false

		if @album and @album.is_public
			@can_read = true
		end
		
		if @album and @album.user == current_user
			@can_read = true
			@can_write = true
		end
		
		
		if @album and current_user
			@permissions = UserAlbumPermission.find_by user_id: current_user.id, album_id: @album.id
			if @permissions
				@can_read = @permissions.can_read
				@can_write = @permissions.can_edit
			end
		end
		
		if not @can_read
			@folders = []
			@files = []
			flash[:alert] = "You do not have permissions to view this album."
		else
			flash[:alert] = ""
			#@folders = Pathname.new(@root_dir).children.select { |c| c.directory? and c.basename.to_s != '.thumb' }.collect { |p| p.to_s.sub(@root_dir,'') }.sort
			#@folders = Album.where(:path => @album.full_path)
			@folders = Album.where(:album => @album)
			@files = Pathname.new(@root_dir).children
				.select { |c| c.to_s.downcase.end_with?('jpg') or c.to_s.downcase.end_with?('jpeg') or c.to_s.downcase.end_with?('png') }
				.sort.collect { |p| [p.to_s.gsub(Rails.application.config.image_folder_path, ''), FastImage.size(p.to_s)
] }
		end
	end

	def new
		@album = Album.new
		if params.has_key?(:album_id)
			@album.album = Album.find(params[:album_id])
		end
	end

	def create
		@album = Album.new(user_params)
		@album.user = current_user
		if @album.save
			newDir = File.join(Rails.application.config.image_folder_path, @album.path, @album.name)
			Dir.mkdir(newDir) unless File.exists?(newDir)
			redirect_to(action: 'show', id: @album)
		end
	end

	def edit
		@album = Album.find(params[:id])
	end

	def update
		@album = Album.find(params[:id])
		@album.update_attributes(user_params)
		redirect_to(action: 'show', id: @album)
	end

  private

  def user_params
    params.require(:album).permit(:album_id, :name, :is_public)
  end
end
