%w(coffeescript sassy closure require).each do |tool|
  require "keystone/asset_tools/#{tool}"
end