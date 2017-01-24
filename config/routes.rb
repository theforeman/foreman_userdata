Rails.application.routes.draw do
  get 'userdata/meta-data', :controller => 'userdata', :action => 'metadata', :format => 'text'
  get 'userdata/user-data', :controller => 'userdata', :action => 'userdata', :format => 'text'
end
