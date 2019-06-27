class Transmitter < ApplicationRecord
	has_many :programs, dependent: :destroy
	validates_presence_of :name
	require 'open-uri'

	# def past_days
	# 	Time.now - 1
	# end

	# def advance_days
		
	# end

	def get_transmitter
		i = 0
		stop = false
		until stop do
			url  =  "https://www.tvspielfilm.de/tv-programm/sendezeit/?page=#{i}&date=2019-06-27"
			doc = send_request(url)
	    data =  doc.css('div.program-channel ul.channel-list li a')
	    stop = true unless data.present?
			transmitters = []
	    data.each do |d|
	      transmitters << d.attributes['title'].value.delete(" Programm")
	    end
	  	get_programs(transmitters, doc)
	    i+=1
	  end

	end

	def get_programs(transmitters, doc)
	  data = doc.css('div.program-info ul.program-info-list li.uslisting')
		i = 0
    data.css("ul.channel-list").each do |list|
    	transmitter = Transmitter.where(name: transmitters[i]).first_or_initialize
    	transmitter.save
    	puts list.css("li").count
    	list.css("li").each do |pro|
    		begin
      		name = pro.css("div.topholder a.aholder").text
      		href = pro.css("div.topholder a.aholder")[0].attributes["href"].value
      		time = pro.css("spanclass").text
      		next unless time.present?
      		time = time.delete(" ").split("-")
      		program  = Program.where(name: name ).first_or_initialize
      		program.update(transmitter_id: transmitter.id)

					ep = Episode.where(source_url: href).first_or_initialize
					ep.update(program_id: program.id , start_time: time[0], end_time: time[1] ,program_date: "2019-06-27" ,source_url: href)
    		rescue Exception => e
    			puts e
    		end
    	end
    	i+=1
  	end
	end

	def create_episode_info
		Episode.all.each do |e_info|
			e_info.get_episode_info
		end
	end

	def send_request(url)
	  Nokogiri::HTML(open(url))
	end
end

# video_arr = []
# video_arr.flatten!.compact!
# get_video_url=''
# video_arr.each do |url|
# get_video_url= url if url.include?('https://video') && url.include?('.mp4')
# end
# get_video_url