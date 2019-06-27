class Episode < ApplicationRecord
	has_many :episode_infos, dependent: :destroy
	has_many :ratings, dependent: :destroy
	belongs_to :program
	require 'open-uri'

	def get_episode_info
		url = source_url
		doc 				= send_request(url)
		data 				= doc.css("article.broadcast-detail")
		header 			= doc.css("header.broadcast-detail__header")
		duration 		= header.css("div.text-wrapper span.text-row")[1].text[-7..-2] rescue nil
		# channel 		= header.css("span.tv-show-label__channel").text
		# video 			= data.css("section.broadcast-detail__stage video#videoContainercontentElement")
		description = doc.css("section.broadcast-detail__description p").text.delete("\"").delete("\r").delete("\n")
		cast 				= doc.css("section.cast dl")
		casts 			= get_cast(cast[0])
		actors 			= get_cast(cast[1])

		# header
		# transmitter_valid(channel)
		# Länge,Originaltitel
    self.program.update(genre: casts["Genre"]) if (casts["Genre"].present? && program.genre.nil?)
		
		self.update(duration: duration) if casts["Länge"].present?

    self.episode_infos.create(description: description, country: casts["Land"], year: casts["Jahr"],age_rating: casts["Altersfreigabe"], director: casts["Regie"],  producer: casts["Produzent"], script: casts["Drehbuch"], camera: casts["Kamera"], music: casts["Musik"], original_title: casts["Originaltitel"], actors: actors)
  	#crate Rating
  	get_rating(header)
	end

	def send_request(url)
	  Nokogiri::HTML(open(url))
	end

	def get_rating(header)
		header = header.css('section.broadcast-detail__rating')
		thumb = header.css('div.editorial-rating')[0].values[0].split(" ")[1] rescue nil
		header.css('ul.rating-dots li').each do |li|
			puts source_text = li.css("span").text rescue nil
			puts rate = li.css("span")[1].attributes["data-rating"].value rescue 0
			self.ratings( source: source_text, rating: rate ) 
		end
		self.update(thumb: thumb) if thumb.present?
	end

	def get_cast(cast)
		begin			
			a = []
			cast.css("dt").each do |c|
				a << c.text.delete(":")
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
		if channel.present? && program.transmitter.name != channel
    	 t = Transmitter.find_by(name: channel)
    	 program.update(transmitter_id: t.id) if t.present?
    end	
	end
end
