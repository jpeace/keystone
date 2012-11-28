module Keystone
  class AssetCompiler
    include AssetContainer
    
    attr_reader :package_name, :toolchain, :post_build, :post_build_ignore_patterns

    def initialize(toolchain, assets=[], options={})
      @compiled = false
      @package = nil

      @toolchain = toolchain.map {|t| t.new}
      @originals = @assets = assets
      
      @package_name = options[:package_name]
      @post_build = (options[:post_build] || []).map {|t| t.new}
      @post_build_ignore_patterns = options[:post_build_ignore_patterns] || []
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

    def reset!
      @assets.each do |a|
        unless a.location_on_disk.nil?
          a.type = @originals.find {|o| o.path == a.path && o.name == a.name}.type
          a.content = File.read(a.location_on_disk)
        end
      end
      @compiled = false
    end

    def build!
      if @package.nil?
        compile!

        non_pb_assets, pb_assets = @assets.partition {|a| @post_build_ignore_patterns.any? {|re| re.match(a.name)}}
        non_pb_package, pb_package = [non_pb_assets, pb_assets].map do |assets|
          Asset.new do |a|
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
  end
end