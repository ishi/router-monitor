#encoding: UTF-8

class StatisticValuesController < ApplicationController
  def index
    @statistic_values = StatisticValue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statistic_values }
    end
  end

  def show
    @statistic_value = StatisticValue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @statistic_value }
    end
  end

  def new
    @statistic_value = StatisticValue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @statistic_value }
    end
  end

  def edit
    @statistic_value = StatisticValue.find(params[:id])
  end

  def create
    @statistic_value = StatisticValue.new(params[:statistic_value])

    respond_to do |format|
      if @statistic_value.save
		CRON::Sender.send_task @statistic_value
        format.html { redirect_to statistic_values_url, notice: 'Dodano nową wartość.' }
        format.json { render json: @statistic_value, status: :created, location: @statistic_value }
      else
        format.html { render action: "new" }
        format.json { render json: @statistic_value.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @statistic_value = StatisticValue.find(params[:id])

    respond_to do |format|
      if @statistic_value.update_attributes(params[:statistic_value])
		CRON::Sender.send_task @statistic_value
        format.html { redirect_to statistic_values_url, notice: 'Pomyśnie zmodyfikowano wartość.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @statistic_value.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @statistic_value = StatisticValue.find(params[:id])
    @statistic_value.destroy
	CRON::Sender.send_task @statistic_value
    respond_to do |format|
      format.html { redirect_to statistic_values_url }
      format.json { head :ok }
    end
  end

  private
end
