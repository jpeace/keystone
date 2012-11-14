module Keystone
  class PipelineConfiguration
    attr_reader :asset_path, :tool_modules

    def initialize
      @tool_modules = []
    end
  end

  class AssetConfiguration
    attr_reader :scan_paths, :tools, :post_build_steps

    def initialize
      @scan_paths = []
      @tools = []
      @post_build_steps = []
    end
  end

  class ConfigurationError < StandardError
  end
end