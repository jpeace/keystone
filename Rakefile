require 'bundler/setup'
require 'jasmine-headless-webkit'

task :default => 'jasmine:headless'

Jasmine::Headless::Task.new('jasmine:headless') do |t|
  t.colors = true
  t.keep_on_error = true
  t.jasmine_config = 'spec/jasmine/support/jasmine.yml'
end