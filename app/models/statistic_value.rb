# encoding: UTF-8
require 'rrd'

class StatisticValue < ActiveRecord::Base
	validates :print_name, :script, :presence => { :message => "nie może być puste" }
	validates :name, :uniqueness => true
	validates :interval, :numericality => { :only_integer => true, :greater_than => 0, :message => "musi być więkrze od 0" }
	
	before_validation :create_value_name 
	after_create :create_rrd_base
	after_update :update_rrd_base
	before_destroy :remove_rrd_base

	def update_rrd value
		rrd.update Time.now, value
	end

	private
	
	def create_value_name
	  self.name = self.print_name.downcase.gsub(/[^a-zA-Z0-9]/, '-')
	end

	def rrd
		@rrd ||= lambda {
			`mkdir -p #{File.dirname file_name}`
			raise Exception.new "Nie udało się utworzyć katalogu z bazami rrd" unless $?.to_i.zero?

			RRD::Base.new(file_name)
		}.call
	end

	def create_rrd_base
		Rails.logger.info "Tworzę bazę danych #{file_name}"
		
		step = interval.to_i
		name = self.name
		
		rrd.create :start => Time.now, :step => step.seconds do
			datasource name, :type => :gauge, :heartbeat => (step * 2).seconds
			archive :average, :every => step.seconds, :during => (step * 1440).seconds
			archive :average, :every => (step * 5).seconds, :during => (step * 5 * 2016).seconds
			archive :average, :every => (step * 30).seconds, :during => (step * 30 * 1488).seconds
			archive :average, :every => (step * 300).seconds, :during => (step * 300 * 1752).seconds
		end
	end

	def update_rrd_base
		create_rrd_base unless File.exist? file_name
	end

	def remove_rrd_base
		Rails.logger.info "Usówam bazę danych rrd #{file_name}"
		File.unlink(file_name)
  rescue => e
    Rails.logger.error "Nie udane usunięcie bazy danych rrd #{file_name} " + e.message
  end

	def file_name
		@fiel_name ||= File.join(Rails.root, 'tmp', 'rrd', "#{self.name}.rrd")
	end
end
