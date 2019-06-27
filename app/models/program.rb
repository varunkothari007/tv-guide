class Program < ApplicationRecord
	has_many :episodes, dependent: :destroy
	belongs_to :transmitter
	validates_presence_of :name
end
