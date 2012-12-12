module Keystone
  class PipelineConfiguration
    attr_accessor :asset_path
    attr_reader :tool_modules, :assets

    class << self
      def from_file(path)
        self.new(File.read(path))
      end
    end

    def initialize(script='')
      @tool_modules = []
      @assets = []
      
      dsl = Keystone::Dsl::PipelineExpression.new(self)
      dsl.instance_eval(script)
    end

    def add_tool_module(mod)
      @tool_modules << mod
    end

    def add_asset_config(asset)
      @assets << asset
    end
  end

  class AssetConfiguration
    attr_reader :name, :external_compilers, :scan_paths, :tools, :post_build_steps, :post_build_ignore_patterns

    def initialize(name)
      @name = name
      @external_compilers = []
      @scan_paths = []
      @tools = []
      @post_build_steps = []
      @post_build_ignore_patterns = []
    end

    def add_external_compiler(compiler)
      @external_compilers << compiler
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

    def add_post_build_ignore_pattern(pattern)
      @post_build_ignore_patterns << pattern
    end
  end

  class ConfigurationError < StandardError
  end
end