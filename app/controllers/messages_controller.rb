class MessagesController < Messages::Base
  skip_before_action :set_message, only: [:new, :create]

  def new
    @message = Message.new message_params
    set_message_warning
  end

  def create
    @message = Message.new message_params
    @message.publisher = current_user

    if @message.save
      flash[:success] = 'Message published!'
      redirect_to message_path(@message)
    else
      flash.now[:danger] = 'Unable to publish message!'
      set_message_warning
      render :new
    end
  end

  def show
  end

  def destroy
    if @message.destroy
      flash[:warning] = 'Message deleted!'
      return_back
    else
      flash[:danger] = 'Unable to delete message!'
      redirect_back
    end
  end

  private

  def set_message_warning
    unless current_user.can_publish?
      flash.now[:warning] = 'You published a message in this period already. You can push one message every 24 hours.'
    end
  end

  def message_params
    return unless params[:message].present?
    params.require(:message).permit(:content)
  end

  def authenticated?
    if show_action?
      return true
    end

    if create_action? || destroy_action?
      return true if user_signed_in?
    end
  end

  def authorized?
    if create_action? || show_action?
      return true
    end

    if destroy_action?
      return true if current_user == @message.publisher
    end
  end
end
