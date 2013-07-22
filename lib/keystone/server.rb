require 'sinatra'

module Keystone
  class Server < ::Sinatra::Base
    @@pipeline = nil
    @@asset_hashes = Hash.new('')

    @@mime_types = Hash.new('text/plain')
    @@mime_types[Keystone::Types::Javascript] = 'text/javascript'
    @@mime_types[Keystone::Types::Css] = 'text/css'

    class << self
      attr_accessor :pipeline
    end

    get '*' do
      return [404, 'Not Found'] if @@pipeline.nil?
      
      @@pipeline.compilers.each do |compiler|
        safe_compile! compiler
        
        asset = find_asset_in_compiler compiler

        unless asset.nil?
          content_type @@mime_types[asset.type], :charset => 'utf-8'
          return [200, asset.content]
        end
      end

      [404, 'Not Found']
    end

    module Helpers
      
      # Forces a reload from disk if compilation fails
      def safe_compile!(compiler)
        begin
          compiler.compile!
        rescue
          recompile_assets!(compiler)
        end
      end 

      def self.included(mod)
        mod.helpers do
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
                  tags << tag_for_asset(path, a.type, :add_extension => true)
                end
              end
              tags.join("\n")
            else
              path = compiler.package_name
              path = "#{base}/#{path}" unless base == ''
              tag_for_asset(path, compiler.package_type)
            end
          end

          def tag_for_asset(name, type, options={})
            add_extension = options[:add_extension] || false
            path = add_extension ? "#{name}#{AssetLoader.extension_from_type(type)}" : name
            case
              when [Keystone::Types::Javascript, Keystone::Types::Coffeescript].include?(type)
                %{<script type="text/javascript" src="/#{path}"></script>}
              when [Keystone::Types::Css, Keystone::Types::Sassy].include?(type)
                %{<link rel="stylesheet" type="text/css" href="/#{path}" />}
              else
                ""
            end
          end
        end
      end
    end


    private

    def requested_path
      @requested_path ||= params[:splat].first[1..-1]
    end

    def requested_filename
      @requested_filename ||= requested_path.split('/').last
    end

    def requested_type
      @requested_type ||= AssetLoader.type_from_filename(requested_filename)
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

    def find_asset_in_compiler compiler
      asset = compiler.asset(requested_path)

      if asset.nil?
        asset = find_asset_in_externals
      elsif asset.type == requested_type
        if need_to_rebuild_asset? asset
          recompile_assets! compiler
          asset = compiler.asset(requested_path)
        end
      end

      asset
    end

    def find_asset_in_externals
      parsed = /^((?:\w+\/)*)(\w+)(\.(\w+))?$/.match(requested_path)
      path = parsed[1].gsub(/\/$/,'')
      name = parsed[2]
      extension = parsed[4]

      results = compiler.external_assets.select{ |asset| asset.path == path && asset.name == name }
      extension.nil? ? results.first : results.find{ |asset| asset.type == Keystone::AssetLoader.type_from_extension(extension) }
    end

    def need_to_rebuild_asset? asset
      asset.current_hash != @@asset_hashes[requested_path]
    end

  end
end