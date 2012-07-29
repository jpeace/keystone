asset 'titan.js' do |a|
  a.paths 'views/coffee', 'public/js'
  a.toolchain :cofeescript, :closure, :require
end

asset 'titan.css' do |a|
  a.paths 'views/scss', 'public/css'
  a.toolchain :sassy
end