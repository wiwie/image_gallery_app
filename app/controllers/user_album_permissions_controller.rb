class UserAlbumPermissionsController < ApplicationController
	def new
		@perm = UserAlbumPermission.new
		if params[:album_id]
			@perm.album = Album.find(params[:album_id])
		end
	end

	def create
		@perm = UserAlbumPermission.new(user_params)
		if @perm.save
			redirect_to(controller: 'albums', action: 'index', path: File.join(@perm.album.path, @perm.album.name))
		end
	end

  private

  def user_params
    params.require(:user_album_permission).permit(:user_id, :album_id, :can_read, :can_write)
  end
end
