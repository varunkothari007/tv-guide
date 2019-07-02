class Episode < ApplicationRecord
	has_many :episode_infos, dependent: :destroy
	has_many :ratings, dependent: :destroy
	# validates :source_url, uniqueness: true
	belongs_to :program
	require 'open-uri'

	def get_episode_info
		url = source_url
		# url = "https://www.tvspielfilm.de/tv-programm/sendung/miss-undercover,5cd28786818965652bf912ab.html"
		# url = "https://www.tvspielfilm.de/tv-programm/sendung/monitor,5cda852e81896518171f509c.html"
		doc 				= send_request(url)
		data 				= doc.css("article.broadcast-detail")
		# header 			= doc.css("header.broadcast-detail__header")
		# duration 		= header.css("div.text-wrapper span.text-row")[1].text[-7..-2] rescue nil
		channel 		= doc.css("span.tv-show-label__channel").text
		video 			= get_video_url(doc)
		description = doc.css("section.broadcast-detail__description p").text.delete("\"").delete("\r").delete("\n")
		cast 				= doc.css("section.cast dl")
		casts 			= get_cast(cast[0])
		actors 			= get_cast(cast[1])
		thumb = doc.css('div.editorial-rating')[0].values[0].split(" ")[1] rescue nil
		# transmitter_valid(channel)
		image = doc.css(".broadcast-detail__stage img").first.attributes["src"].value rescue []
    self.program.update(genre: casts["Genre"]) if (casts["Genre"].present? && program.genre.nil?)
		self.update(preview_video_url: video, is_scraped: true) 
    self.episode_infos.create(description: description, country: casts["Land"], year: casts["Jahr"],age_rating: casts["Altersfreigabe"], director: casts["Regie"],  producer: casts["Produzent"], script: casts["Drehbuch"], camera: casts["Kamera"], music: casts["Musik"], original_title: casts["Originaltitel"], actors: actors ,thumb: thumb, image_urls: image)
    get_rating(doc)
	end

	def send_request(url)
	  Nokogiri::HTML(open(url))
	end

	def get_rating(doc)
		rate_data = []
		
		doc.css('ul.rating-dots li').each do |li|
			source_text = li.css("span").text rescue nil
			rate = li.css("span")[1].attributes["data-rating"].value rescue nil
			rating = Rating.source_present(id, source_text) if (source_text.present? && rate.present?)
			unless rating.present?
				rate_data << { episode_id: id ,source: source_text, rating: rate } if (source_text.present? && rate.present?)
			end
		end
		
		source_text = doc.css("div.rating-stars").text.delete(" ").delete("\n").delete("\t") rescue nil
		rate = doc.css("div.rating-stars span")[1].attributes['data-rating'].value  rescue 0
		rating = Rating.source_present(id, source_text) if (source_text.present? && rate.present?)
		
		unless (rating.present?)
			rate_data << { episode_id: id ,source: source_text, rating: rate } if (source_text.present? && rate.present?)
		end
		
		Rating.create(rate_data) if rate_data.present?
	end

	def get_video_url(doc)
		string =  doc.css("#playerHtmlOld script").text
		return nil unless string.present?
		video_arr = string.scan(/(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/)
		return nil unless video_arr.present?
		video_arr.flatten!.compact! 
		get_video_url=''
		video_arr.each do |url|
			get_video_url = url if url.include?('https://video') && url.include?('.mp4')
		end
		get_video_url
	end

	def get_cast(cast)
		begin			
			a = []
			cast.css("dt").each do |c|
				a << c.text.delete(":").delete("\r\n")
			end
			b = []
			cast.css("dd").each do |c|
				b << c.text.delete(" ").delete("\r").delete("\n")
			end
			c ={}
			for i in 0..a.count-1 do
				c[a[i]] = b[i]
			end
			return c
		rescue Exception => e
			return {}
		end
	end

	def transmitter_valid(channel)
		begin	
			if channel.present? && program.transmitter.name != channel
	    	 t = Transmitter.find_by(name: channel)
	    	 program.update(transmitter_id: t.id) if t.present?
	    end	
		rescue Exception => e
			p e
		end
	end
end
