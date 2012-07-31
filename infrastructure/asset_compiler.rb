module MusicOne
  class Asset
    attr_accessor :name, :type, :content
    def initialize
      yield self if block_given?
    end
  end

  class AssetLoader
    class << self
      def type_from_filename(filename)
        extensions = {
          :coffee => ['coffee'],
          :javascript => ['js'],
          :sassy => ['scss'],
          :css => ['css']
        }

        ext = filename.split('.').last
        found = extensions.select {|type, exts| exts.include? ext}.first
        if found.nil?
          :unknown
        else
          found[0]
        end
      end
    end
  end

  class AssetCompiler
    attr_accessor :assets

    def initialize(toolchain, assets=[])
      @compiled = false
      @package = nil

      @toolchain = toolchain.map {|t| t.new}
      @assets = assets
    end

    def [](asset_name)
      @assets.select {|a| a.name == asset_name}.first
    end

    def compiled?
      @compiled
    end

    def compile!
      return if compiled?
      @assets = @assets.map do |a|
        @toolchain.reduce(a) {|asset,tool| tool.run!(asset)}
      end
      @compiled = true
    end

    def build!
      if @package.nil?
        compile!
        @package = @assets.map{|a| a.content}.join("\n")
      end
      @package
    end
  end

  module AssetTool
    attr_reader :original

    def run!(asset)
      @original = asset  
      if should_run? 
        new_content = transform
        if new_content.is_a? Array
          new_type = new_content[0]
          new_content = new_content[1]
        end
        MusicOne::Asset.new do |a|
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