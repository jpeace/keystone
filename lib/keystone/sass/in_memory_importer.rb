require 'sass'

module Keystone
  module Sass
    class InMemoryImporter < ::Sass::Importers::Base
      @@modules = {}
      class << self
        def add_module(path, content)
          @@modules[path] = content
        end

        def key(uri, options)
          ["InMemoryImport_#{uri}", uri]
        end

        def find_relative(uri, base, options)
          full_path = base.gsub(/\/[\w\-]+$/, '') # Remove file name from path
          # Now build up the rest of the path
          uri.split('/').each do |part|
            if part == '..'
              full_path.gsub!(/\/[\w\-]+$/, '')
            else
              full_path = "#{full_path}/#{part}"
            end
          end
      
          return nil if @@modules[full_path].nil?

          options.merge!({
            :syntax => :scss,
            :filename => full_path,
            :importer => self
          })
          ::Sass::Engine.new(@@modules[full_path], options)
        end
      end

      def initialize(paths)
      end

      def find(uri, options)
        return nil if @@modules[uri].nil?

        options.merge!({
          :syntax => :scss,
          :filename => uri,
          :importer => self.class
        })
        ::Sass::Engine.new(@@modules[uri], options)
      end

      def mtime(uri, options)
        nil
      end

      def to_s
        'InMemoryImporter'
      end
    end
  end
end