assets_are_in "#{File.dirname(__FILE__)}"
add_tools TestObjects::AssetTools

asset 'titan.js' do |a|
  a.scan 'views/coffee', 'public/js'
  a.toolchain :coffeescript, :closure
  a.post_build :require
end

asset 'titan.css' do |a|
  a.scan 'views/scss', 'public/css'
  a.toolchain :sassy
end