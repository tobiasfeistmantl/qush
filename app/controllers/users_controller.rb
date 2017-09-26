class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :confirm]
  before_action :authorize!

  def new
    @user = User.new user_params
  end

  def create
    @user = User.new user_params

    if @user.save
      UserMailer.email_confirmation(@user).deliver_now
      flash[:success] = 'Signed up successfully. We sent you a confirmation message to your email address.'
      return_back
    else
      flash.now[:danger] = 'Unable to sign you up'
      render :new
    end
  end

  def show
    @messages = @user.messages
  end

  def edit
  end

  def update
    if @user.update user_edit_params
      flash[:success] = 'Profile updated!'
      return_back
    else
      flash.now[:danger] = 'Uanble to update profile!'
      render :edit
    end
  end

  def confirm
    if !@user.confirmed?
      if @user.confirmation_token == params[:confirmation_token]
        if @user.update confirmed: true
          flash[:success] = 'User confirmed! You can sign in now.'
          redirect_to signin_path
        else
          flash[:danger] = 'Unable to confirm user!'
          return_back
        end
      else
        flash[:danger] = 'Invalid confirmation token!'
        return_back
      end
    else
      flash[:warning] = 'User already confirmed!'
      return_back
    end
  end

  private

  def authenticated?
    if create_action?
      return true unless user_signed_in?
    end

    if show_action?
      return true
    end

    if update_action?
      return true if user_signed_in?
    end

    if action_name == 'confirm'
      return true
    end
  end

  def authorized?
    if create_action? || show_action?
      return true
    end

    if update_action?
      return true if current_user == @user
    end

    if action_name == 'confirm'
      return true
    end
  end

  def user_params
    return unless params[:user].present?
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_edit_params
    return unless params[:user].present?
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def set_user
    @user = User.find params[:user_id] || params[:id]
  end
end