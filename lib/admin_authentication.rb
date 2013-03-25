module AdminAuthentication

  SuperUsers = %w(<anonymized>@gmail.com <anonymized>@gmail.com)

  def super_user_required
    return true if super_user?
    flash[:error] = 'Unauthorized entry'
    redirect_to '/'
    return false
  end

  def super_user?(user = self.current_user)
    logged_in? and SuperUsers.include?(user.login)
  end
  
  #add these functions as a helper method to any including library
  #(since the including library is the parent controller, it gets added
  #as a helper function who's scope is any controller!)
  def self.included(base)
    begin
      base.send(:helper_method, :super_user?)
    rescue #I don't care if the class doesn't have helper methods
    end
  end
end
