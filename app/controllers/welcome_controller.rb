class WelcomeController < ApplicationController
  
  def index
    redirect_to :controller => :admin if logged_in?
  end
  
  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if self.current_user.nil?
      flash[:error] = 'Incorrect password or login'
      redirect_to :action => :index    
    else #we made it
      redirect_to :controller => :admin
    end
  end

  def signout
    logout_internal
    redirect_to '/'
  end

  def test_email
    render :text => Notifier.deliver_test_email
  end

  private
  #the internal code to logout - decomped due to multiple use
  def logout_internal
    self.current_user.forget_me if logged_in?
    reset_session
    cookies.delete :auth_token
  end 

end
