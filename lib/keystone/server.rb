require 'sinatra'

module Keystone
  class Server < ::Sinatra::Base
    @@pipeline = nil
    class << self
      def pipeline
        @@pipeline
      end
      def pipeline=(pipeline)
        @@pipeline = pipeline
      end
    end

    get '*' do
      return [404, 'Not Found'] if @@pipeline.nil?

      requested_path = params[:splat].first[1..-1]
      asset = nil

      @@pipeline.compilers.each do |c|
        c.reset!
        c.compile!
        asset = c.asset(requested_path)
        break unless asset.nil?
      end

      if asset.nil?
        [404, 'Not Found']
      else
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
              compiler.compile!
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