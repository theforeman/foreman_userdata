module ForemanUserdata
  class Engine < ::Rails::Engine
    engine_name 'foreman_userdata'

    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]

    initializer 'foreman_userdata.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_userdata do
        requires_foreman '>= 1.12'
        template_labels 'cloud-init' => N_('cloud-init')
      end
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanUserdata::Engine.load_seed
      end
    end
  end
end
