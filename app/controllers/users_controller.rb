class UsersController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    unless @user
      render_404 
    end
  end
end
