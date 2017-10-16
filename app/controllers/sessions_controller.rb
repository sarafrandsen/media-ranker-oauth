class SessionsController < ApplicationController

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      user = User.find_by(provider: params[:provider], uid: auth_hash['uid'])
      if user.nil?
        # User has not logged in before
        # Create a new record in the DB
        user = User.from_auth_hash(params[:provider], auth_hash)
        save_and_flash(user)

      else
        flash[:status] = :success
        flash[:message] = "Successfully logged in as returning user #{user.name}"

      end
      session[:user_id] = user.id

    else
      flash[:status] = :failure
      flash[:message] = "Could not create user from OAuth data"
    end

    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:message] = "You have been logged out"
    redirect_to root_path
  end
end
