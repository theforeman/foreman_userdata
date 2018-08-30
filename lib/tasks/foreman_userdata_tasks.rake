# Tasks
namespace :foreman_userdata do
  namespace :example do
    desc 'Example Task'
    task task: :environment do
      # Task goes here
    end
  end
end

# Tests
namespace :test do
  desc 'Test ForemanUserdata'
  Rake::TestTask.new(:foreman_userdata) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_userdata do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_userdata) do |task|
        task.patterns = ["#{ForemanUserdata::Engine.root}/app/**/*.rb",
                         "#{ForemanUserdata::Engine.root}/lib/**/*.rb",
                         "#{ForemanUserdata::Engine.root}/test/**/*.rb"]
      end
    rescue LoadError
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_userdata'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_userdata']

load 'tasks/jenkins.rake'
Rake::Task['jenkins:unit'].enhance ['test:foreman_userdata', 'foreman_userdata:rubocop'] if Rake::Task.task_defined?(:'jenkins:unit')
