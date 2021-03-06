module Keystone
  module Dsl
    class AssetExpression
      attr_reader :config

      def initialize(config, settings={})
        @config = config
        @tool_modules = settings[:tool_modules] || []
        @asset_path = settings[:asset_path] || ''
      end

      def add_assets_from(compiler)
        @config.add_external_compiler(compiler)
      end

      def scan(*paths)
        paths.each do |path|
          scan_path = nil
          if path.is_a? Hash 
            scan_path = Keystone::ScanPath.new(path[:path], path[:namespace])
          else
            scan_path = Keystone::ScanPath.new(path)
          end
          raise Keystone::ConfigurationError.new("Bad scan path: #{scan_path.path}") unless File.directory?("#{@asset_path}/#{scan_path.path}")
          @config.add_scan_path(scan_path)
        end
      end

      def toolchain(*tools)
        tools.each { |t| @config.add_tool(find_tool(t)) }
      end

      def post_build(*tools)
        tools.each { |t| @config.add_post_build_step(find_tool(t)) }
      end

      def skip_post_build_for(*patterns)
        patterns.each do |pattern|
          if pattern.is_a? Regexp
            @config.add_post_build_ignore_pattern(pattern)
          elsif pattern.is_a? String
            @config.add_post_build_ignore_pattern(/^#{pattern}$/)
          else
            raise Keystone::ConfigurationError.new("Bad post-build pattern given: #{pattern}")
          end
        end
      end

      private

      def find_tool(tool)
        @tool_modules.each do |mod|
          begin
            klass = mod.const_get(class_name_from_symbol(tool))
            return klass
          rescue
          end
        end
        raise Keystone::ConfigurationError.new("Bad tool given for toolchain: #{tool}")
      end

      def class_name_from_symbol(sym)
        class_name = sym.to_s
        separator = /_(\w)/
        class_name.scan(separator).count.times do
          pieces = class_name.partition(separator)
          class_name = pieces[0] + $~[1].upcase + pieces[2]
        end
        class_name[0] = class_name[0].upcase
        return class_name
      end
    end
  end
end