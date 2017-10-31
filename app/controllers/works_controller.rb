class WorksController < ApplicationController
  # We should always be able to tell what category
  # of work we're dealing with
  skip_before_action :require_login, only: [:root, :index, :show]
  before_action :category_from_work, except: [:root, :index, :new, :create]

  def root
    @albums = Work.best_albums
    @books = Work.best_books
    @movies = Work.best_movies
    @best_work = Work.order(vote_count: :desc).first
  end

  def index
    if find_user
      @works_by_category = Work.to_category_hash
    else
      redirect_to root_path
    end
  end

  def new
    if find_user
      @work = Work.new
    else
      redirect_to root_path
    end
  end

  def create
    @work = Work.new(media_params)
    @work.user_id = @login_user.id
    @media_category = @work.category
    if @work.save
      flash[:status] = :success
      flash[:result_text] = "Successfully created #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not create #{@media_category.singularize}"
      flash[:messages] = @work.errors.messages
      render :new, status: :bad_request
    end
  end

  def show
    if find_user
      @votes = @work.votes.order(created_at: :desc)
    else
      redirect_to root_path
    end
  end

  def edit
    if find_user
      if @work.user_id != @login_user.id
        flash[:status] = :failure
        flash[:result_text] = "You do not have permissions to edit this #{@media_category.singularize}"
        redirect_to work_path(@work.id)
      end
    else
      redirect_to root_path
    end
  end

  def update
    @work.update_attributes(media_params)
    if @work.save
      flash[:status] = :success
      flash[:result_text] = "Successfully updated #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not update #{@media_category.singularize}"
      flash.now[:messages] = @work.errors.messages
      render :edit, status: :not_found
    end
  end

  def destroy
    if @work.user_id == @login_user.id
      @work.destroy
      flash[:status] = :success
      flash[:result_text] = "Successfully destroyed #{@media_category.singularize} #{@work.id}"
      redirect_to root_path
    else
      flash[:status] = :failure
      flash[:result_text] = "You do not have permissions to delete this #{@media_category.singularize}"
      redirect_to work_path(@work.id)
    end
  end

  def upvote
    # Most of these varied paths end in failure
    # Something tragically beautiful about the whole thing
    # For status codes, see
    # http://stackoverflow.com/questions/3825990/http-response-code-for-post-when-resource-already-exists
    flash[:status] = :failure
    if find_user
      vote = Vote.new(user: @login_user, work: @work)
      if vote.save
        flash[:status] = :success
        flash[:result_text] = "Successfully upvoted!"
        status = :found
      else
        flash[:result_text] = "Could not upvote"
        flash[:messages] = vote.errors.messages
        status = :conflict
      end
    else
      flash[:result_text] = "You must log in to do that"
      status = :unauthorized
    end

    # Refresh the page to show either the updated vote count
    # or the error message
    redirect_back fallback_location: work_path(@work), status: status
  end

  private
  def media_params
    params.require(:work).permit(:title, :category, :creator, :description, :publication_year)
  end

  def category_from_work
    @work = Work.find_by(id: params[:id])
    render_404 unless @work
    @media_category = @work.category.downcase.pluralize
  end
end
