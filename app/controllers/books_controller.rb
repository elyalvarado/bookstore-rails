class BooksController < ApplicationController
  # GET /books
  def index
    @books = Book.limit(params[:limit])

    render json: @books, include: ["author"], meta: {total: Book.count}
  end

  # GET /books/1
  def show
    @book = Book.find(params[:id])

    render json: @book
  end
end
