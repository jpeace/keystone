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
      asset = nil

      @@pipeline.compilers.each do |c|
        Keystone::Server.safe_compile!(c)
        
        asset = c.asset(requested_path)
        if !asset.nil? && (asset.current_hash != @@asset_hashes[requested_path])
          Keystone::Server.rebuild_hashes!(c)
          asset = c.asset(requested_path)
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
              compiler.assets.each do |a|
                path = (a.path == '') ? a.name : "#{a.path}/#{a.name}"
                unless base == ''
                  path = "#{base}/#{path}"
                end
                tags << tag_for_asset(path, a.type)
              end
              tags.join("\n")
            else
              path = compiler.package_name
              path = "#{base}/#{path}" unless base == ''
              tag_for_asset(path, compiler.package_type)
            end
          end

          def tag_for_asset(name, type)
            case
              when [Keystone::Types::Javascript, Keystone::Types::Coffeescript].include?(type)
                %{<script type="text/javascript" src="#{name}"></script>}
              when [Keystone::Types::Css, Keystone::Types::Sassy].include?(type)
                %{<link rel="stylesheet" type="text/css" href="#{name}" />}
              else
                ""
            end
          end
        end
      end
    end
  end
end