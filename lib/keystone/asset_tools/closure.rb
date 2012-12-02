require 'closure-compiler'

module Keystone
  module AssetTools
    class Closure
      include Keystone::AssetTool
      def should_run?(asset)
        asset.type == Keystone::Types::Javascript
      end
      def transform(asset)
        # ::Closure::Compiler.new(:compilation_level => 'WHITESPACE_ONLY').compile(asset.content)
        ::Closure::Compiler.new.compile(asset.content)
      end
    end
  end
end