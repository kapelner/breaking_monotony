source 'http://rubygems.org'

gem 'rails', '3.1'
gem "exception_notification",
        :git => "git://github.com/rails/exception_notification.git",
        :require => "exception_notifier"
gem 'crypt19'


group :production do  
  gem 'nokogiri'
  gem 'mysql2', :git => 'git://github.com/brianmario/mysql2.git'
end

gem 'rturk'
gem 'carrierwave'
gem 'jammit'
gem 'yui-compressor'
gem 'POpen4'

group :development do
  gem 'mysql'
  gem 'win32-open3-19', :platforms => :mingw
  #make dev nicer
  gem 'rails-dev-boost'
  #handy tools to make the console and logging pretty
  gem 'win32console'
  gem 'hirb'
  gem 'wirble'
  gem 'awesome_print'
end

#this stuff is for testing
group :test, :development do
  gem 'webrat'
  gem 'ZenTest'
  gem 'i18n'
  gem 'autotest'
end