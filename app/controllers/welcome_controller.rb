class WelcomeController < ApplicationController
  def root
    redirect_to newsfeed_path if user_signed_in?
    @user = User.new
  end

  private

  def authorized?
    return true
  end

  def authenticated?
    return true
  end
end
