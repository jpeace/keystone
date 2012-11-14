module Keystone
  class PipelineConfiguration
    attr_accessor :asset_path
    attr_reader :tool_modules, :assets

    def initialize
      @tool_modules = []
      @assets = []
    end

    def add_tool_module(mod)
      @tool_modules << mod
    end

    def add_asset_config(asset)
      @assets << asset
    end
  end

  class AssetConfiguration
    attr_reader :scan_paths, :tools, :post_build_steps

    def initialize
      @scan_paths = []
      @tools = []
      @post_build_steps = []
    end

    def add_scan_path(path)
      @scan_paths << path
    end

    def add_tool(tool)
      @tools << tool
    end

    def add_post_build_step(tool)
      @post_build_steps << tool
    end
  end

  class ConfigurationError < StandardError
  end
end