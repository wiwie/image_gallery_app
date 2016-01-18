require 'RMagick'
require 'fileutils'

class ImagesController < ApplicationController
	include Magick

	def serve
		path = params[:filename]
		width = params[:width]
		if width
			# if the user requests the original size, then we set width to nil here.
			# it will then be set to the larger dimensions below
			if width == 'orig'
				width = nil
			else
				width = width.to_i
			end
		else
			width = 1024
		end

		if path.to_s.include? Rails.application.config.image_folder_path
			dims = FastImage.size(path.to_s)

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
	end

	def serve_thumbnail
		path = "#{params[:filename]}"

		if path.to_s.include? Rails.application.config.image_folder_path

			t_path = path + '.thumb'
			if not File.exists?(t_path)
				thumbnail(path,t_path, 128)
			end
		    send_file( t_path,
		      :disposition => 'inline',
		      :type => 'image/jpeg',
		      :x_sendfile => true )
		end
	end
	
    def thumbnail(source, target, width, height = nil)
      return nil unless File.file?(source)
      height ||= width

      img = Image.read(source).first
      rows, cols = img.rows, img.columns

      source_aspect = cols.to_f / rows
      target_aspect = width.to_f / height
      thumbnail_wider = target_aspect > source_aspect

      factor = thumbnail_wider ? width.to_f / cols : height.to_f / rows
      img.thumbnail!(factor)
      img.crop!(CenterGravity, width, height)

      FileUtils.mkdir_p(File.dirname(target))
      img.write(target) { self.quality = 75 }
    end
end
