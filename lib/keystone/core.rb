%w(types configuration asset asset_container asset_compiler asset_loader asset_pipeline asset_tool).each do |dep|
  require "keystone/core/#{dep}"
end