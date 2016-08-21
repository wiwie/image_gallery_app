require 'rmagick'
require 'fileutils'

class ImagesController < ApplicationController
	include Magick

	def ensure_processed(myImg)
		if not myImg.processed
			img = Magick::Image.read(File.join(Rails.application.config.image_folder_path, myImg.full_path)).first
			begin
				rot_img = img.auto_orient!
				# if this is nil, the image was properly oriented before
				if rot_img
					# the image is now properly oriented
					# overwrite original image
					rot_img.write(newFile.to_s)
				end
			rescue
			ensure
				if img
					img.destroy!
				end
				if rot_img
					rot_img.destroy!
				end
			end
			myImg.processed = true
			myImg.save
		end
	end

	def serve
		img = MyImage.find(params[:id])
		ensure_processed(img)

		path = File.join(Rails.application.config.image_folder_path,
			img.full_path)

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
			pn = Pathname.new(path)
			ext = File.extname(pn)
			filename = File.basename(pn, ext)
			thumb_dir = File.join(Rails.application.config.image_folder_path, img.album.full_path, '.thumb')
			t_path = File.join(thumb_dir, filename + '_' + width.to_s + ext)
			
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

	def serve_thumbnail
		img = MyImage.find(params[:id])
		ensure_processed(img)

		path = File.join(Rails.application.config.image_folder_path, img.full_path)
		pn = Pathname.new(path)
		ext = File.extname(pn)
		filename = File.basename(pn, ext)
		thumb_dir = File.join(Rails.application.config.image_folder_path, img.album.full_path, '.thumb')
		t_path = File.join(thumb_dir, filename + '_thumb_' + 256.to_s + ext)
		
		if not File.exists?(t_path)
			thumbnail(path,t_path, 256)
		end
	    send_file( t_path,
	      :disposition => 'inline',
	      :type => 'image/jpeg',
	      :x_sendfile => true )
	end
	
    def thumbnail(source, target, width, height = nil)
		return nil unless File.file?(source)
		#height ||= width

		img = Image.read(source).first
		begin
			rows, cols = img.rows, img.columns

			source_aspect = cols.to_f / rows
			#target_aspect = width.to_f / height
			#thumbnail_wider = target_aspect > source_aspect
			thumbnail_wider = true

			factor = thumbnail_wider ? width.to_f / cols : height.to_f / rows
			img.sample!(factor)
			#img.crop!(CenterGravity, width, height)

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
