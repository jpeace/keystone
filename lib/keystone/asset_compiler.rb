module Keystone
  class AssetCompiler
    attr_reader :package_name, :assets, :toolchain, :post_build

    def initialize(toolchain, assets=[], options={})
      @compiled = false
      @package = nil

      @toolchain = toolchain.map {|t| t.new}
      @assets = assets

      @package_name = options[:package_name]
      @post_build = (options[:post_build] || []).map {|t| t.new}
    end

    def [](asset_name)
      @assets.select {|a| a.name == asset_name}.first
    end

    def package_name
      @package_name || package_type.to_s
    end

    def package_type
      @assets.first.type unless @assets.empty?
    end

    def compiled?
      @compiled
    end

    def compile!
      return if compiled?
      @toolchain.each {|t| @assets = t.run(@assets)}
      @compiled = true
    end

    def build!
      if @package.nil?
        compile!
        @package = Asset.new do |a|
          a.name = package_name
          a.type = package_type
          a.content = @assets.map{|a| a.content}.join("\n")
        end
        @post_build.each {|t| @package = t.run([@package]).first}
      end
      @package
    end
  end
end