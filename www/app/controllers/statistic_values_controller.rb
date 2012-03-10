#encoding: UTF-8

class StatisticValuesController < ApplicationController
  before_filter :find_value, :only => [:show, :edit, :update, :activate, :destroy]
  
  def index
    @statistic_values = StatisticValue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statistic_values }
    end
  end

  def show
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
    respond_to do |format|
      if @statistic_value.update_attributes(params[:statistic_value])
        CRON::Sender.send_task @statistic_value
        format.html { redirect_to statistic_values_url, notice: 'Zmodyfikowano wartość.' }
        format.json { head :ok }
      else
        format.html { render action: "edit", error: "Błąd podczas zapisu wartości do bazy" }
        format.json { render json: @statistic_value.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def activate
    respond_to do |format|
      before = @statistic_value.active?
      if @statistic_value.update_attributes(params[:statistic_value])
        CRON::Sender.send_task @statistic_value
        format.html { redirect_to statistic_values_url, notice: "#{ @statistic_value.active? ? 'A' : 'De' }ktywowano wartość #{@statistic_value.print_name}." }
        format.json { head :ok }
      else
        format.html { redirect_to statistic_values_url, error: "Nieudana #{ @statistic_value.active? ? 'de' : '' }aktywacja wartości #{@statistic_value.print_name}." }
        format.json { render json: @statistic_value.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @statistic_value.destroy
    CRON::Sender.send_task @statistic_value
    respond_to do |format|
      format.html { redirect_to statistic_values_url }
      format.json { head :ok }
    end
  end

  private
  def find_value
    @statistic_value = StatisticValue.find(params[:id])
  end
end
