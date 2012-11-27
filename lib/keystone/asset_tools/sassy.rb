require 'sass'

module Keystone
  module AssetTools
    class Sassy

      def run(assets)
        modules = []
        templates = []
        transformed = []

        # First make a sweep and identify all modules, loading them into the Sass importer
        assets.each do |asset|
          if asset.name[0] == '_'
            modules << asset
            Keystone::Sass::InMemoryImporter.add_module("#{asset.path}/#{asset.name[1..-1]}", asset.content)
          else
            templates << asset
          end
        end

        # Now compile all of the templates
        templates.each do |template|
          if template.type == Keystone::Types::Sassy
            transformed << Keystone::Asset.new do |a|
              a.name = template.name
              a.type = Keystone::Types::Css
              a.path = template.path
              a.location_on_disk = template.location_on_disk
              a.content = compile(template.content)
            end
          else
            transformed << template
          end
        end
        return transformed
      end

      def compile(content)
        ::Sass::Engine.new(content, :syntax => :scss, :filesystem_importer => Keystone::Sass::InMemoryImporter).render
      end
    end
  end
end