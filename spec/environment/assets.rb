asset_path "#{File.dirname(__FILE__)}"

asset 'titan.js' do |a|
  a.paths 'views/coffee', 'public/js'
  a.toolchain :coffeescript, :closure, :require
end

asset 'titan.css' do |a|
  a.paths 'views/scss', 'public/css'
  a.toolchain :sassy
end