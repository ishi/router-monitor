#!/usr/bin/env ruby
# encoding: UTF-8

RAILS_ROOT = File.dirname(File.dirname(File.dirname(__FILE__)))

# You might want to change this
ENV["RAILS_ENV"] ||= File.exist?(File.join(RAILS_ROOT, 'development.env')) && 'development' || 'production'

require File.expand_path('../../../config/application.rb', __FILE__)
Rails.application.require_environment!
require 'open4'


module CRON
  SCRIPT_PATH = File.join(Rails.root, 'tmp', 'scripts')
  
  
  class CronLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
    end 
  end
  
	class CronJob
		attr_accessor :job

		def initialize(job)
			@job = job
			@jobFile = Tempfile.new([@job.name, '.tmp.sh'], SCRIPT_PATH)
			@jobFile.chmod(0500)
			@jobFile.write(@job.script.gsub(/\r/, ''))
			@jobFile.close
		end

		def call job
			pid, stdin, stdout, stderr = Open4::popen4 "sh -c #{@jobFile.path}"
			stdin.close

			ignored, status = ::Process::waitpid2 pid
			value = stdout.read.strip
			Rails.logger.info "Wykonałem zadanie #{@job.name}, INTERVAL:[#{@job.interval}] RETURN_CODE:[#{ status.exitstatus }] VALUE:[#{ value }]"

			Rails.logger.debug "[TASK] #{@job.name} pid        : #{ pid }"
			Rails.logger.debug "[TASK] stdout     : #{ value }"
			Rails.logger.debug "[TASK] status     : #{ status.inspect }"
			Rails.logger.debug "[TASK] exitstatus : #{ status.exitstatus }"
			if status.exitstatus.zero?
				@job.update_rrd value
			else
        Rails.logger.error "[TASK] Błąd podczas wykonywania zadania: #{ stderr.read.strip }"
			end
		rescue Exception => e
			Rails.logger.error "Wyjątek podczas wykonywania skryptu #{@job.name}: #{e}"
		end
	end
	
	class Cron < EM::Connection
		@@values = {}
		@@scheduler = nil
		
		def self.scheduler=(scheduler)
			@@scheduler = scheduler
		end

		def self.scheduler
			@@scheduler ||= Rufus::Scheduler::EmScheduler.start_new(:frequency => 10.0)
		end

		def receive_data(data)
			data = data.to_i
			Cron.remove data
			return if !StatisticValue.exists? data
			job = StatisticValue.find(data)
			return if !job.active?
			Cron.add job
		rescue ActiveRecord::RecordNotFound => e
			Rails.logger.error "Wyjątek podcza wyszukiwania rekordu o id #{data}, #{e}"
		end
		
		def self.add job
			cron_job = CronJob.new(job)
			@@values[job.id] = [cron_job, (scheduler.every "#{job.interval}s", cron_job, :first_in => '1s')]
			Rails.logger.info "Dodano zadanie #{job.name}"
		end

		def self.remove id
			return unless @@values.has_key? id
			@@values[id][1].unschedule
			Rails.logger.info "Usunięto zadanie #{@@values[id][0].job.name}"
			@@values.delete(id)
		end

	end

  logfile = File.open("#{Rails.root}/log/cron.log", 'a')
  logfile.sync = true
  Rails.logger = CronLogger.new(logfile)
  Rails.logger.level = Logger::INFO unless 'development' == Rails.env
  
  Rails.logger.debug "Uruchamiam server w środowisu #{Rails.env}"
  
  Dir.mkdir SCRIPT_PATH unless File.directory? SCRIPT_PATH

  Rails.logger.info 'Zaczynam nasłuchiwać'
	EM.run do
		Signal.trap("INT")  { EM.stop }
		Signal.trap("TERM") { EM.stop }

		StatisticValue.active.each { |v| Cron.add v }
		server = EM.start_server("127.0.0.1", 22223, Cron)
	end
  Rails.logger.info 'Bye...'
end
