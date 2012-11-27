require 'coffee-script'

module Keystone
  module AssetTools
    class Coffeescript
      include Keystone::AssetTool
      def should_run?(asset)
        asset.type == Keystone::Types::Coffeescript
      end
      def transform(asset)
        [Keystone::Types::Javascript, "return #{CoffeeScript.compile(asset.content)}"]
      end
    end
  end
end