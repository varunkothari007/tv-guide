class Rating < ApplicationRecord
	belongs_to :episode
	validates_presence_of :source, :rating
	validates :source, uniqueness: { scope: :episode_id }
end
