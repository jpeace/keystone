require 'bundler/setup'
require 'rspec/core/rake_task'
require 'echoe'
  
Echoe.new("keystone", "0.0.1") do |p|  
  p.description     = "Asset pipeline"  
  p.url             = "http://musiconelive.com"  
  p.author          = "Music One Live"  
  p.email           = "admin@musiconelive.com"  
  p.ignore_pattern  = FileList[".gitignore"]  
  p.development_dependencies = []
  p.runtime_dependencies = []
end  

task :default => ['rspec']

desc "Run rspec specs"
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.rspec_opts = '-dcfd --require spec_helper'
end