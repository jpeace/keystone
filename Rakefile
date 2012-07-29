require 'bundler/setup'
require 'jasmine-headless-webkit'
require 'rspec/core/rake_task'

task :default => ['rspec', 'jasmine:headless']

desc "Run rspec specs"
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.rspec_opts = '-dcfd --require rspec/spec_helper'
end

desc "Runs jasmine specs"
Jasmine::Headless::Task.new('jasmine:headless') do |t|
  t.colors = true
  t.keep_on_error = true
  t.jasmine_config = 'spec/jasmine/support/jasmine.yml'
end