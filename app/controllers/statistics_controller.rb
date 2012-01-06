require 'rrd'

class StatisticsController < ApplicationController
	before_filter :set_graph_values, :only => [:index, :generate]
	
	def index
		params[:date_from] = (Time.new - 1.day).strftime("%d.%m.%Y %H:%M")
		params[:date_to] = Time.new.strftime("%d.%m.%Y %H:%M")
		render :generate
	end

	def generate
		return redirect_to :action => 'index' if params[:date_from].blank? || params[:date_to].blank? || params[:el].blank?
		if params[:offset]
			offset = params[:offset]
			site = offset[:right] || offset[:left]
			start_time = Time.parse(params[:date_from])
			end_time = Time.parse(params[:date_to])
			diff = end_time - start_time
			diff = (diff / 2).round if site[:half]
			diff *= -1 if offset[:left]
			params[:date_from] = (start_time + diff).strftime("%d.%m.%Y %H:%M")
			params[:date_to] = (end_time + diff).strftime("%d.%m.%Y %H:%M")
		end

		@file = create_filename(params)
		dir = stats_dir
		elements = params[:el]
		RRD.graph File.join(charts_dir, @file), graph_params(params) do
			elements.each do |id, el|
 				next unless el[:value]
				obj = StatisticValue.find(el[:value])
				area File.join(dir, "#{obj.name}.rrd"), obj.name.to_sym => :average, :color => "#{el[:color]}A0", :label => obj.print_name
			end
		end
	end

	def log
	end

	private

	def set_graph_values
		@values = StatisticValue.all
	end

	def create_filename (params)
		from = params[:date_from].gsub(/[ :.]/, "")
		to = params[:date_to].gsub(/[ :.]/, "")
		elements = params[:el].collect { |k, e| "#{e[:value]}_#{e[:color].gsub(/#/, '')}" if e[:value] }.compact.join '_'
		"#{from}_#{to}_#{elements}.png"
	end

	def graph_params(params)
		{:width => 1000, :height => 500, :color => ["FONT#000000", "BACK#FFFFFF"], :start => Time.parse(params[:date_from]), :end => Time.parse(params[:date_to])}
	end

	def charts_dir
		dir = File.join(Rails.root, "public", "charts")
		Dir.mkdir(dir) unless File.directory? dir
		Open4::popen4 "find #{dir} -mmin +1 | xargs rm"
		dir
	end

	def stats_dir
		@stats_dir ||= File.join(Rails.root, 'tmp', 'rrd')
	end
end
