module Keystone
  class AssetCompiler
    include AssetContainer
    
    attr_reader :package_name, :toolchain, :external_assets, :post_build, :post_build_ignore_patterns

    def initialize(toolchain, assets=[], options={})
      @compiled = false
      @package = nil

      @toolchain = toolchain.map {|t| t.new}
      @originals = @assets = assets
      
      @external_assets = options[:external_assets] || []
      @package_name = options[:package_name]
      @post_build = (options[:post_build] || []).map {|t| t.new}
      @post_build_ignore_patterns = options[:post_build_ignore_patterns] || []
    end

    def package_name
      @package_name || package_type.to_s
    end

    def package_type
      if @assets.empty?
        if @external_assets.empty?
          Keystone::Types::Unknown
        else
          @external_assets.first.type
        end
      else
        @assets.first.type
      end
    end

    def compiled?
      @compiled
    end

    def compile!
      return if compiled?
      @toolchain.each {|t| @assets = t.run(@assets)}
      @compiled = true
    end

    def reset!
      to_remove = []
      @assets.each do |a|
        if a.location_on_disk.nil?
          # This was generated by one of the build tools, we'll want to remove it
          to_remove << a
        else
          a.type = @originals.find {|o| o.path == a.path && o.name == a.name}.type
          a.content = File.read(a.location_on_disk)
        end
      end
      to_remove.each {|a| @assets.delete(a)}
      @compiled = false
    end

    def build!
      if @package.nil?
        compile!

        combined_assets = clean_duplicated_assets(@assets + @external_assets)

        non_pb_assets, pb_assets = combined_assets.partition {|a| @post_build_ignore_patterns.any? {|re| re.match(a.name)}}
        non_pb_package, pb_package = [non_pb_assets, pb_assets].map do |assets|
          Asset.new do |a|
            a.type = package_type
            a.content = assets.map{|a| a.content}.join("\n")
          end
        end
        @post_build.each {|t| pb_package = t.run([pb_package]).first}

        @package = Asset.new do |a|
          a.name = package_name
          a.type = package_type
          a.content = "#{pb_package.content}\n#{non_pb_package.content}"
        end
        
      end
      @package
    end

    private 

    def clean_duplicated_assets(assets)
      unique_assets = [ ]

      assets.each do |asset|
        unique_assets << asset unless unique_assets.select {|test_asset| test_asset.content == asset.content}.length > 0
      end

      unique_assets
    end

  end
end