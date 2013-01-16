require 'sinatra'

module Keystone
  class Server < ::Sinatra::Base
    @@pipeline = nil
    @@asset_hashes = Hash.new('')

    @@mime_types = Hash.new('text/plain')
    @@mime_types[Keystone::Types::Javascript] = 'text/javascript'
    @@mime_types[Keystone::Types::Css] = 'text/css'

    class << self
      def pipeline
        @@pipeline
      end
      def pipeline=(pipeline)
        @@pipeline = pipeline
      end
      
      # Forces a reload from disk if compilation fails
      def safe_compile!(compiler)
        begin
          compiler.compile!
        rescue
          rebuild_hashes!(compiler)
        end
      end    

      # Reloads files from disk and recalculates MD5 hashes
      def rebuild_hashes!(compiler)
        compiler.reset!
        compiler.compile!
        compiler.assets.each do |a|
          path_and_name = a.path == '' ? a.name : "#{a.path}/#{a.name}"
          @@asset_hashes[path_and_name] = a.current_hash
        end
      end    
    end

    get '*' do
      return [404, 'Not Found'] if @@pipeline.nil?
      
      requested_path = params[:splat].first[1..-1]
      requested_filename = requested_path.split('/').last
      requested_type = AssetLoader.type_from_filename(requested_filename)
      asset = nil

      @@pipeline.compilers.each do |c|
        Keystone::Server.safe_compile!(c)
        
        asset = c.asset(requested_path)
        unless asset.nil?
          asset = nil unless asset.type == requested_type
        end

        if !asset.nil? && (asset.current_hash != @@asset_hashes[requested_path])
          Keystone::Server.rebuild_hashes!(c)
          asset = c.asset(requested_path)
          unless asset.nil?
            asset = nil unless asset.type == requested_type
          end
        end

        if asset.nil?
          parsed = /^((?:\w+\/)*)(\w+)(\.(\w+))?$/.match(requested_path)
          path = parsed[1].gsub(/\/$/,'')
          name = parsed[2]
          extension = parsed[4]

          results = @assets.select{ |a| a.path == path && a.name == name }
          if extension.nil?
            asset = results.first
          else
            asset = results.find{ |a| a.type == Keystone::AssetLoader.type_from_extension(extension) }
          end
        end
      
        break unless asset.nil?
      end

      if asset.nil?
        [404, 'Not Found']
      else
        content_type @@mime_types[asset.type], :charset => 'utf-8'
        [200, asset.content]
      end
    end

    module Helpers
      def self.included(mod)
        mod.helpers do
          def load_asset(asset_name, options={})
            base = options[:base] || ''

            compiler = Keystone::Server.pipeline.compiler(asset_name)
            raise "No compiler found for #{asset_name}" if compiler.nil?

            if ENV['RACK_ENV'] == 'development'
              Keystone::Server.safe_compile!(compiler)
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
  end
end