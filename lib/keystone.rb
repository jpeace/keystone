require 'keystone/version'
%w(core dsl asset_tools server rake_task).each do |dep|
  require "keystone/#{dep}"
end

module Keystone
  class << self
    def bootstrap(config_path)
      build_pipeline(Keystone::PipelineConfiguration.from_file(config_path))
    end

    def build_pipeline(config)
      compilers = []

      config.assets.each do |asset_config|
        loader = AssetLoader.new(config.asset_path)
        asset_config.scan_paths.each do |path|
          loader.scan!(path)
        end
        compilers << AssetCompiler.new(asset_config.tools, loader.assets, 
          :post_build => asset_config.post_build_steps, 
          :post_build_ignore_patterns => asset_config.post_build_ignore_patterns, 
          :package_name => asset_config.name)
      end

      AssetPipeline.new(compilers)
    end
  end
end