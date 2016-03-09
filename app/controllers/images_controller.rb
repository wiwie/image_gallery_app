require 'RMagick'
require 'fileutils'

class ImagesController < ApplicationController
	include Magick

	def serve
		path = File.join(Rails.application.config.image_folder_path,params[:filename])

		path = rotate_and_get_rotated_path(path)

		width = params[:width]
		if width
			# if the user requests the original size, then we set width to nil here.
			# it will then be set to the larger dimensions below
			if not width == 'orig'
				width = width.to_i
			end
		else
			width = 1024
		end

		dims = FastImage.size(path.to_s)

		# if the user requests the original size, set it to the larger dimension here.
		if width == 'orig'
			width = dims.max
		end

		if dims.max > width
			t_path = path + '.thumb' + '_' + width.to_s
			if not File.exists?(t_path)
				if dims[0] > dims[1]
					factor = dims[0]/width.to_f
					thumbnail(path,t_path, width, dims[1]/factor)
				else
					factor = dims[1]/width.to_f
					thumbnail(path,t_path, dims[0]/factor, width)
				end
			end
		    send_file( t_path,
		      :disposition => 'inline',
		      :type => 'image/jpeg',
		      :x_sendfile => true )
		    return
		end
		send_file( path,
	      :disposition => 'inline',
	      :type => 'image/jpeg',
	      :x_sendfile => true )
	end

	def rotate_and_get_rotated_path(path)
		pn = Pathname.new(path)

		dir = pn.dirname
		ext = File.extname(pn)
		filename = File.basename(pn, ext)

		thumb_dir = File.join(dir,'.thumb')

		Dir.mkdir(thumb_dir) unless File.exists?(thumb_dir)

		#rotated_path = File.join(thumb_dir,filename.to_s + '.rot' + ext)
		rotated_path = path

		if not File.exists?(rotated_path)
			img = Magick::Image.read(path).first
			begin
				rot_img = img.auto_orient
				rot_img.write(rotated_path)
			rescue
			ensure
				if img
					img.destroy!
				end
				if rot_img
					rot_img.destroy!
				end
			end
		end
		return rotated_path
	end

	def serve_thumbnail
		path = File.join(Rails.application.config.image_folder_path, "#{params[:filename]}")

		path = rotate_and_get_rotated_path(path)

		dir = File.dirname(path)
		ext = File.extname(path)
		filename = File.basename(path, ext)

		thumb_dir = File.join(dir,'.thumb')
		Dir.mkdir(thumb_dir) unless File.exists?(thumb_dir)

		t_path = File.join(thumb_dir, filename + '.thumb' + ext)
		if not File.exists?(t_path)
			thumbnail(path,t_path, 128)
		end
	    send_file( t_path,
	      :disposition => 'inline',
	      :type => 'image/jpeg',
	      :x_sendfile => true )
	end
	
    def thumbnail(source, target, width, height = nil)
		return nil unless File.file?(source)
		height ||= width

		img = Image.read(source).first
		begin
			rows, cols = img.rows, img.columns

			source_aspect = cols.to_f / rows
			target_aspect = width.to_f / height
			thumbnail_wider = target_aspect > source_aspect

			factor = thumbnail_wider ? width.to_f / cols : height.to_f / rows
			img.sample!(factor)
			img.crop!(CenterGravity, width, height)

			FileUtils.mkdir_p(File.dirname(target))
			img.write(target) { self.quality = 75 }
		rescue
		ensure
			if img
				img.destroy!
			end
		end
    end
end
