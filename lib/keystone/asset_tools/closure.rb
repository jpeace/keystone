require 'closure-compiler'

module Keystone
  module AssetTools
    class Closure
      include Keystone::AssetTool
      def should_run?
        @original.type == Keystone::Types::Javascript
      end
      def transform
        ::Closure::Compiler.new.compile(@original.content)
      end
    end
  end
end