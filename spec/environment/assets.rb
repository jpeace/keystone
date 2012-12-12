assets_are_in ENV['ASSET_PATH']
add_tools TestObjects::AssetTools

asset 'keystone.js' do |a|
  a.scan 'js', 'coffee'
  a.toolchain :coffeescript, :require
  a.post_build :closure
  a.skip_post_build_for 'support', /\.coffee$/
end

asset 'keystone.css' do |a|
  a.scan 'scss', 'css'
  a.toolchain :sassy
end