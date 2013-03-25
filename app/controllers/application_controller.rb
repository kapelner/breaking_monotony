class ApplicationController < ActionController::Base
  protect_from_forgery

  include AuthenticatedSystem
  include AdminAuthentication

  helper :all # include all helpers, all the time

  before_filter :big_brother_track #track the user stuff all the time
  
  ControllersNotToTrack = %w()
  def big_brother_track
    #don't log certain controller's activity
    return if ControllersNotToTrack.include?(controller_name)
    #now log it:
    bbt = BigBrotherTrack.create({
      :controller => controller_name,
      :action => params[:action],
      :user_id => self.current_user == :false || self.current_user.nil? ? nil : self.current_user.id,
      :user_login => self.current_user == :false || self.current_user.nil? ? nil : self.current_user.login,
      :ip => request.remote_ip,
      :method => request.method.to_s,
      :ajax => request.xhr?,
      :entry => params[:entry], #it's important man!!!
      :language => params[:language]
    })

    # Log the parameters.
    params.each do |key, val|

      #we've already got these:
      next if %w(action controller entry language).include?(key)

      # Don't retain files
      next unless val.is_a?(String)
      BigBrotherParam.create({
        :param => key.to_s,
        :value => val.to_s,
        :big_brother_track => bbt
      })
    end
    true #we always "pass"
  end
end
