require 'keystone/version'
%w(types dsl configuration asset asset_compiler asset_loader asset_pipeline asset_tool asset_tools).each do |dep|
  require "keystone/#{dep}"
end

module Keystone
  class << self
    def build_pipeline(config)
      compilers = []

      config.assets.each do |asset_config|
        loader = AssetLoader.new(config.asset_path)
        asset_config.scan_paths.each do |path|
          loader.scan!(path)
        end
        compilers << AssetCompiler.new(asset_config.tools, loader.assets, :post_build => asset_config.post_build_steps, :package_name => asset_config.name)
      end

      AssetPipeline.new(compilers)
    end
  end
end