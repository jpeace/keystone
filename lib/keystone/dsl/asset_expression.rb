module Keystone
  module Dsl
    class AssetExpression
      attr_reader :config

      def initialize(settings={})
        @config = Keystone::AssetConfiguration.new
      end

      def scan(*paths)
      end

      def toolchain(*tools)
      end

      def post_build(*tools)
      end
    end
  end
end