def asset_path
  "#{File.dirname(__FILE__)}../../environment/assets"
end

module TestObjects

  module AssetTools
    class ReplaceQs
      include Keystone::AssetTool
      def should_run?
        true
      end
      def transform
        @original.content.gsub(/[qQ]/, '*')
      end
    end

    class ReplaceCaps
      include Keystone::AssetTool
      def should_run?
        true
      end
      def transform
        @original.content.gsub(/[A-Z]/, '-')
      end
    end

    class DoubleString
      include Keystone::AssetTool
      def should_run?
        @original.type == :too_short
      end
      def transform
        doubled = ''
        @original.content.each_char {|c| doubled << "#{c}#{c}"}
        [:doubled, doubled]
      end
    end

    class ShortenString
      include Keystone::AssetTool
      def should_run?
        true
      end
      def transform
        @original.content[1,100]
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
        a.content = "How Quick is Shaq?"
      end
    end

    def asset2
      Keystone::Asset.new do |a|
        a.name = "asset2"
        a.type = :too_short
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
  
end