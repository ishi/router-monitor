# encoding: UTF-8
require 'rrd'

class StatisticValue < ActiveRecord::Base
	after_create :create_rrd_base
	after_update :update_rrd_base
	before_destroy :remove_rrd_base

	def update_rrd value
		rrd.update Time.now, value
	end

	private

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
		
		rrd.create :start => Time.now, :step => step.minutes do
			datasource name, :type => :gauge, :heartbeat => (step * 2).minutes
			archive :average, :every => step.minutes, :during => (step * 1440).minutes
			archive :average, :every => (step * 5).minutes, :during => (step * 5 * 2016).minutes
			archive :average, :every => (step * 30).minutes, :during => (step * 30 * 1488).minutes
			archive :average, :every => (step * 300).minutes, :during => (step * 300 * 1752).minutes
		end
	end

	def update_rrd_base
		create_rrd_base unless File.exist? file_name
	end

	def remove_rrd_base
		Rails.logger.info "Usówam bazę danych #{file_name}"
		File.unlink(file_name)
	end

	def file_name
		@fiel_name ||= File.join(Rails.root, 'tmp', 'rrd', "#{self.name}.rrd")
	end
end
