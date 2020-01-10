class PublishingHousesController < ApplicationController
  # GET /publishing_houses
  def index
    @publishing_houses = PublishingHouse.all

    render json: @publishing_houses
  end

  # GET /publishing_houses/1
  def show
    @publishing_house = PublishingHouse.find(params[:id])

    render json: @publishing_house
  end
end
