def asset_path
  "#{File.dirname(__FILE__)}/environment/assets"
end

module TestObjects

  module AssetTools
    class ReplaceQs
      include Keystone::AssetTool
      def should_run?(asset)
        asset.type == :boring
      end
      def transform(asset)
        asset.content.gsub(/[qQ]/, '*')
      end
    end

    class ReplaceCaps
      include Keystone::AssetTool
      def should_run?(asset)
        true
      end
      def transform(asset)
        asset.content.gsub(/[A-Z]/, '-')
      end
    end

    class DoubleString
      include Keystone::AssetTool
      def should_run?(asset)
        asset.type == :too_short
      end
      def transform(asset)
        doubled = ''
        asset.content.each_char {|c| doubled << "#{c}#{c}"}
        [:doubled, doubled]
      end
    end

    class ShortenString
      include Keystone::AssetTool
      def should_run?(asset)
        true
      end
      def transform(asset)
        [:shortened, asset.content[1,100]]
      end
    end

    def replace_qs 
      ReplaceQs.new
    end

    def replace_caps
      ReplaceCaps.new
    end

    def double_string
      DoubleString.new
    end
  end

  module Assets
    def asset1
      Keystone::Asset.new do |a|
        a.name = "asset1"
        a.type = :boring
        a.path = 'path/to/file'
        a.location_on_disk = '/home/test/path/to/file'
        a.content = "How Quick is Shaq?"
      end
    end

    def asset2
      Keystone::Asset.new do |a|
        a.name = "asset2"
        a.type = :too_short
        a.location_on_disk = '/home/test/file2'
        a.content = "Quite doubled"
      end
    end

    def asset3
      Keystone::Asset.new do |a|
        a.name = "asset3"
        a.type = :boring
        a.content = "Not quick enough"
      end
    end
  end

  module Compilers
    class FakeCompiler < Keystone::AssetCompiler
      include TestObjects::Assets
      def initialize
        @originals = @assets = [asset1, asset2]
        @toolchain = [TestObjects::AssetTools::DoubleString.new]
        @package_name = 'fake_package'
        @post_build = []
        @post_build_ignore_patterns = []
      end
    end
  end
end