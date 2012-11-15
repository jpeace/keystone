require 'coffee-script'

module Keystone
  module AssetTools
    class Coffeescript
      include Keystone::AssetTool
      def should_run?
        @original.type == Keystone::Types::Coffeescript
      end
      def transform
        [Keystone::Types::Javascript, CoffeeScript.compile(@original.content)]
      end
    end
  end
end