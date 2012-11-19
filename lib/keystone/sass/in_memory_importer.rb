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

      def find_relative(uri, base, options)
        nil
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