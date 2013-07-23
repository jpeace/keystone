module Sinatra
  module KeystoneHelpers

    def load_asset(asset_name, options={})
      base = options[:base] || ''

      compiler = Keystone::Server.pipeline.compiler(asset_name)
      raise "No compiler found for #{asset_name}" if compiler.nil?

      if ENV['RACK_ENV'] == 'development'
        safe_compile!(compiler)
        tags = []
        [compiler.assets, compiler.external_assets].each do |assets|
          assets.each do |a|
            path = (a.path == '') ? a.name : "#{a.path}/#{a.name}"
            unless base == ''
              path = "#{base}/#{path}"
            end
            tags << tag_for_asset(path, a.type, add_extension: true, asset_parent: asset_name)
          end
        end
        tags.join("\n")
      else
        path = compiler.package_name
        path = "#{base}/#{path}" unless base == ''
        tag_for_asset(path, compiler.package_type)
      end
    end
 

    private

    def tag_for_asset(name, type, options={})
      extension = options[:add_extension] ? Keystone::AssetLoader.extension_from_type(type) : ''
      query_string = options[:asset_parent].nil? ? '' : "?asset_parent=#{options[:asset_parent]}"

      path = "#{name}#{extension}#{query_string}"
      
      case
        when [Keystone::Types::Javascript, Keystone::Types::Coffeescript].include?(type)
          %{<script type="text/javascript" src="/#{path}"></script>}
        when [Keystone::Types::Css, Keystone::Types::Sassy].include?(type)
          %{<link rel="stylesheet" type="text/css" href="/#{path}" />}
        else
          ""
      end
    end
    
    # Forces a reload from disk if compilation fails
    def safe_compile!(compiler)
      begin
        compiler.compile!
      rescue
        recompile_assets!(compiler)
      end
    end 

    # Reloads files from disk and recalculates MD5 hashes
    def recompile_assets!(compiler)
      compiler.reset!
      compiler.compile!
      compiler.assets.each do |a|
        path_and_name = a.path == '' ? a.name : "#{a.path}/#{a.name}"
        @@asset_hashes[path_and_name] = a.current_hash
      end
    end 

  end
end