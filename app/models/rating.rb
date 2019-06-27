class Rating < ApplicationRecord
	belongs_to :episode
	validates_presence_of :source, :rating
end
