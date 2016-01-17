require 'RMagick'
require 'fileutils'

class ImagesController < ApplicationController
	include Magick

	def serve
		path = "#{params[:filename]}"

		if path.to_s.include? Rails.application.config.image_folder_path
		    send_file( path,
		      :disposition => 'inline',
		      :type => 'image/jpeg',
		      :x_sendfile => true )
		end
	end

	def serve_thumbnail
		path = "#{params[:filename]}"

		if path.to_s.include? Rails.application.config.image_folder_path
		#filename = Pathname.new(path).basename
		#extension = File.extname(path)

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
