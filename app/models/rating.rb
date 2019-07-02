class Rating < ApplicationRecord
	belongs_to :episode
	validates_presence_of :source, :rating
	validates :source, uniqueness: { scope: :episode_id }
  scope :source_present, ->(s,e_id) { find_by(source: s, episode_id: e_id) }

end
