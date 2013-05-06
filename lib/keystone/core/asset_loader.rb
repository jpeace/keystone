module Keystone
  class AssetLoader
    include AssetContainer

    class << self
      def extensions
        {
          Types::Coffeescript => ['coffee'],
          Types::Javascript => ['js'],
          Types::Sassy => ['scss'],
          Types::Css => ['css']
        }
      end

      def type_from_extension(extension)
        found = extensions.select {|type, exts| exts.include? extension}.first
        if found.nil?
          Types::Unknown
        else
          found[0]
        end
      end

      def type_from_filename(filename)
        type_from_extension(filename.split('.').last)
      end

      def extension_from_type(type)
        ext_array = extensions[type]
        ext_array.nil? ? '' : ".#{ext_array.first}"
      end

      def name_from_filename(filename)
        filename.split('.').first.gsub(/\-\d+/, '')
      end
    end

    def initialize(asset_path)
      @asset_path = asset_path
      @assets = []
    end

    def scan!(scan_path)
      scan_folder(scan_path.path, nil, scan_path.namespace)
    end

    private

    def scan_folder(folder, root_folder=nil, namespace=nil)
      root_folder = folder if root_folder.nil?

      full_path = "#{@asset_path}/#{folder}"

      Dir.foreach(full_path) do |file|
        next if file[/^\./]

        file_path = "#{full_path}/#{file}"
        if File.directory?(file_path)
          new_namespace = namespace.nil? ? nil : "#{namespace}/#{file}"
          scan_folder("#{folder}/#{file}", root_folder, new_namespace)
        else
          filename = file_path[(file_path.rindex('/')+1)..-1]
          @assets << Asset.new do |a|
            a.name = AssetLoader.name_from_filename(filename)
            a.path = folder.gsub(/^#{root_folder}(\/)?/, '')
            a.namespace = namespace
            a.type = AssetLoader.type_from_filename(filename)
            a.content = File.read(file_path)
            a.location_on_disk = File.expand_path(file_path)
          end
        end
      end
    end
  end
end