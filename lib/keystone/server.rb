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

    end

    get '*' do
      return [404, 'Pipeline Not Found'] if @@pipeline.nil?
      return [404, 'Compiler Not Found'] if parent_asset_compiler.nil?

      safe_compile! parent_asset_compiler

      asset = find_asset_in_compiler parent_asset_compiler

      unless asset.nil?
        content_type @@mime_types[asset.type], charset: 'utf-8'
        return [200, asset.content]
      end

      [404, 'Asset Not Found']
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

    def parent_asset_compiler
      @parent_asset_compiler ||= @@pipeline.compiler params[:asset_parent]
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
        asset = find_asset_in_externals compiler
      elsif asset.type == requested_type
        if need_to_rebuild_asset? asset
          recompile_assets! compiler
          asset = compiler.asset(requested_path)
        end
      end

      asset
    end

    def find_asset_in_externals compiler
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