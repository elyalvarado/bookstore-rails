class AuthorsController < ApplicationController
  # GET /authors
  def index
    @authors = Author.all

    render json: @authors
  end

  # GET /authors/1
  def show
    @author = Author.find(params[:id])

    render json: @author, include: ["books"]
  end
end
