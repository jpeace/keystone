module Keystone
  module Dsl
    class PipelineExpression
      attr_reader :config

      def initialize(config)
        @config = config
        @config.add_tool_module(Keystone::AssetTools)
      end

      def assets_are_in(path)
        raise Keystone::ConfigurationError.new("Bad asset path: #{path}") unless File.directory?(path)
        @config.asset_path = path
      end

      def add_tools(*tool_modules)
        tool_modules.each {|m| @config.add_tool_module(m)}
      end

      def asset(name)
        expr = AssetExpression.new(Keystone::AssetConfiguration.new(name), :tool_modules => @config.tool_modules)
        yield expr if block_given?
        @config.add_asset_config(expr.config)
      end
    end
  end
end