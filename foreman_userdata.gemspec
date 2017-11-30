require File.expand_path('../lib/foreman_userdata/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_userdata'
  s.version     = ForemanUserdata::VERSION
  # rubocop:disable Date
  s.date        = Date.today.to_s
  # rubocop:enable Date
  s.authors     = ['Timo Goebel']
  s.email       = ['mail@timogoebel.name']
  s.homepage    = 'http://github.com/theforeman/foreman_userdata'
  s.licenses    = ['GPL-3']
  s.summary     = 'This plug-in adds support for serving user-data for cloud-init to The Foreman.'
  # also update locale/gemspec.rb
  s.description = 'This plug-in adds support for serving user-data for cloud-init to The Foreman.'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rubocop', '0.51.0'
end
