class UserAlbumPermissionsController < ApplicationController
	def new
		@perm = UserAlbumPermission.new
		if params[:album_id]
			@perm.album = Album.find(params[:album_id])
		end
		if current_user
			@albums = Album.where(:user => current_user)
		else
			@albums = []
		end
	end

	def create
		p = user_params
		@perm = UserAlbumPermission.find_by user_id: p[:user_id], album_id: p[:album_id]
		if not @perm
			@perm = UserAlbumPermission.new(p)
		else
			@perm.can_edit = p[:can_edit]
			@perm.can_read = p[:can_read]
		end
		if @perm.save
			redirect_to(controller: 'albums', action: 'index', path: File.join(@perm.album.path, @perm.album.name))
		end
	end

  private

  def user_params
    params.require(:user_album_permission).permit(:user_id, :album_id, :can_read, :can_edit)
  end
end
