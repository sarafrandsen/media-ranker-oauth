class UsersController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]

  def index
    if find_user
      @users = User.all
    else
      redirect_to root_path
    end
  end

  def show
    if find_user
      @user = User.find_by(id: params[:id])
      render_404 unless @user
    else
      redirect_to root_path
    end
  end
end
