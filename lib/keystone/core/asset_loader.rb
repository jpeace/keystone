module Keystone
  class AssetLoader
    include AssetContainer

    class << self
      def type_from_filename(filename)
        extensions = {
          Types::Coffeescript => ['coffee'],
          Types::Javascript => ['js'],
          Types::Sassy => ['scss'],
          Types::Css => ['css']
        }

        ext = filename.split('.').last
        found = extensions.select {|type, exts| exts.include? ext}.first
        if found.nil?
          Types::Unknown
        else
          found[0]
        end
      end

      def name_from_filename(filename)
        filename.split('.').first.gsub(/\-\d+/, '')
      end
    end

    def initialize(asset_path)
      @asset_path = asset_path
      @assets = []
    end

    def scan!(folder)
      scan_folder(folder)
    end

    private

    def scan_folder(folder, root_folder=nil)
      root_folder = folder if root_folder.nil?

      full_path = "#{@asset_path}/#{folder}"

      Dir.foreach(full_path) do |file|
        next if file[/^\./]

        file_path = "#{full_path}/#{file}"
        if File.directory?(file_path)
          scan_folder("#{folder}/#{file}", root_folder)
        else
          filename = file_path[(file_path.rindex('/')+1)..-1]
          @assets << Asset.new do |a|
            a.name = AssetLoader.name_from_filename(filename)
            a.path = folder.gsub(/^#{root_folder}(\/)?/, '')
            a.type = AssetLoader.type_from_filename(filename)
            a.content = File.read(file_path)
            a.location_on_disk = File.expand_path(file_path)
          end
        end
      end
    end
  end
end