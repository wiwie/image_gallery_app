require 'fastimage'

class AlbumsController < ApplicationController
	def index
		@root_dir = Rails.application.config.image_folder_path
		if params.has_key?(:path)
			# we do not allow to go out of our directory
			@root_dir = File.join(@root_dir,params[:path]).gsub('..','.')
		end

		spl = @root_dir.gsub(Rails.application.config.image_folder_path,'').rpartition("/")
		
		@album = Album.find_by path: spl[0], name: spl[2]

		@can_read = false
		@can_write = false

		if @album and (@album.is_public or @album.user == current_user)
			@can_read = true
			@can_write = true
		else
			@permissions = UserAlbumPermission.find_by user: current_user, album: @album
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
			@folders = Pathname.new(@root_dir).children.select { |c| c.directory? and c.basename.to_s != '.thumb' }.collect { |p| p.to_s.sub(@root_dir,'') }.sort
			puts @folders
			@files = Pathname.new(@root_dir).children
				.select { |c| c.to_s.downcase.end_with?('jpg') or c.to_s.downcase.end_with?('jpeg') or c.to_s.downcase.end_with?('png') }
				.sort.collect { |p| [p.to_s.gsub(Rails.application.config.image_folder_path, ''), FastImage.size(p.to_s)
] }
		end
	end

	def new
		@album = Album.new
	end

	def create
		@album = Album.new(user_params)
		@album.user = current_user
		if @album.save
			newDir = File.join(Rails.application.config.image_folder_path, params[:album][:path],params[:album][:name])
			Dir.mkdir(newDir) unless File.exists?(newDir)
			redirect_to(action: 'index', path: File.join(params[:album][:path],params[:album][:name]))
		end
	end

  private

  def user_params
    params.require(:album).permit(:path, :name)
  end
end
