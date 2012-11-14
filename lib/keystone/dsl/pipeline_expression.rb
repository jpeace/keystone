module Keystone
  module Dsl
    class PipelineExpression
      attr_reader :config

      def initialize
        @config = Keystone::PipelineConfiguration.new
      end

      def assets_are_in(*paths)
      end

      def add_tools(*tools)
      end

      def asset
      end
    end
  end
end