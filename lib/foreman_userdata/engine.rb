module ForemanUserdata
  class Engine < ::Rails::Engine
    engine_name 'foreman_userdata'

    initializer 'foreman_userdata.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_userdata do
        requires_foreman '>= 1.12'
      end
    end
  end
end
