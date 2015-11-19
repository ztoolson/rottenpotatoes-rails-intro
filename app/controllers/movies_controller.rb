class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    @sorted_column_css = Hash.new
    @movies = Movie.all

    submitted_ratings = permitted_ratings_params || session[:ratings]
    sort_column = params[:sort_by] || session[:sort_by]

    if params[:ratings]
      session[:ratings] = submitted_ratings
      @movies = @movies.where(:rating => submitted_ratings)

      if sort_column
        session[:sort_by] = sort_column
        @sorted_column_css[sort_column.to_sym] = 'hilite'
        @movies = @movies.order("#{sort_column} asc")
      else
        @movies
      end
    else
      session[:ratings] ||= @all_ratings
      params_backfilled_with_session_info = params.merge(:ratings => session[:ratings])
      redirect_to movies_path(:params => params_backfilled_with_session_info)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def permitted_ratings_params
    return unless params[:ratings]

    ratings = []
    params[:ratings].each do |rating, value|
      ratings << rating if Movie.ratings.include?(rating)
    end
    ratings
  end
end
