class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user
  before_action :require_login

  def render_404
    # DPR: supposedly this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

private
  def find_merchant
    if session[:merchant_id]
      @login_merchant = Merchant.find_by(id: session[:merchant_id])
    end
  end

protected
  def require_login
    @merchant = Merchant.find_by(id: session[:merchant_id])
    unless @merchant
      flash[:status] = :failure
      flash[:message] = "You must be logged in to do that!"
      redirect_to root_path
    end
  end

  def save_and_flash(model)
    result = model.save

    if result
      flash[:status] = :success
      flash[:message] = "Successfully saved #{model.class} #{model.id}"
    else
      flash.now[:status] = :failure
      flash.now[:message] = "Failed to save #{model.class}"
      flash.now[:details] = model.errors.messages
    end

    return result
  end
end
