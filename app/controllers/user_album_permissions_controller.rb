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
			redirect_to(controller: 'albums', action: 'show', id: @perm.album)
		end
	end

	def index
		@album = Album.find(params[:album_id])
		if @album.user != current_user
			flash[:alert] = "You are not the owner of this album."
		else
			@permissions = UserAlbumPermission.where album_id: @album
		end
	end

	def edit
		@perm = UserAlbumPermission.find(params[:id])

		if current_user
			@albums = Album.where(:user => current_user)
		else
			@albums = []
		end
	end

	def update
		@perm = UserAlbumPermission.find(params[:id])

		@perm.update_attributes(user_params)
		redirect_to(action: 'index', album_id: @perm.album)
	end

	def destroy
		@perm = UserAlbumPermission.find(params[:id])
		@album = @perm.album
		@perm.destroy
		redirect_to(controller: 'albums', action: 'show', id: @album)
	end

  private

  def user_params
    params.require(:user_album_permission).permit(:user_id, :album_id, :can_read, :can_edit)
  end
end
