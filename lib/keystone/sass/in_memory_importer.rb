module Keystone
  module Sass
    class InMemoryImporter < Sass::Importers::Base
      class << self
        def templates=(paths)
          @@templates = {}
          paths.each do |path|
            template_pattern = /(([\w\d\-_]+\/)*)_([\w\d\-_]+)\.[\w]+/
            matches = template_pattern.match(path)
            unless matches.nil?
              @@templates["#{matches[1]}#{matches[3]}"] = File.read("#{sass_path}/#{path}")
            end
          end
        end

        def key(uri, options)
          ["InMemoryImport_#{uri}", uri]
        end
      end

      def initialize(paths)
      end

      def find(uri, options)
        return nil if @@templates[uri].nil?

        options.merge!({
          :syntax => :scss,
          :filename => uri,
          :importer => self.class
        })
        Sass::Engine.new(@@templates[uri], options)
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

# InMemoryImporter.templates = ['lib2/_styles.scss', 'lib1/_base.scss']

# template = File.read("#{sass_path}/test.scss")
# engine = Sass::Engine.new(template, :syntax => :scss, :filesystem_importer => InMemoryImporter)
# output = engine.render
# puts output