module Keystone
  module AssetTool
    attr_reader :original

    def run(asset)
      @original = asset  
      if should_run? 
        new_content = transform
        if new_content.is_a? Array
          new_type = new_content[0]
          new_content = new_content[1]
        end
        Asset.new do |a|
          a.name = @original.name
          a.type = new_type || @original.type
          a.content = new_content
        end
      else
        @original
      end
    end

    private

    def should_run?
      true
    end

    def transform
      [@original.type, @original.content]
    end
  end
end