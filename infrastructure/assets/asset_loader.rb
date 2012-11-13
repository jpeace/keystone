module MusicOne
  module Assets
    class AssetLoader
      attr_reader :assets

      class << self
        def type_from_filename(filename)
          extensions = {
            :coffee => ['coffee'],
            :javascript => ['js'],
            :sassy => ['scss'],
            :css => ['css']
          }

          ext = filename.split('.').last
          found = extensions.select {|type, exts| exts.include? ext}.first
          if found.nil?
            :unknown
          else
            found[0]
          end
        end

        def name_from_filename(filename)
          filename.split('.').first
        end
      end

      def initialize(asset_path)
        @asset_path = asset_path
        @assets = []
      end

      def assets(name_or_type=nil)
        return @assets if name_or_type.nil?

        if name_or_type.is_a? Symbol
          return @assets.select {|a| a.type == name_or_type}
        elsif name_or_type.is_a? String
          return @assets.select {|a| a.name == name_or_type}
        end

        return nil
      end

      def asset(path_and_name)
        path = ''
        name = path_and_name
        slash = path_and_name.rindex('/')
        unless slash.nil?
          path = path_and_name[0,slash]
          name = path_and_name[slash+1..-1]
        end

        return @assets.find{ |a| a.path == path && a.name == name }
      end

      def scan!(folder)
        scan_folder(folder)
      end

      private

      def scan_folder(folder)
        full_path = "#{@asset_path}/#{folder}"

        Dir.foreach(full_path) do |file|
          next if ['.', '..'].include?(file)

          file_path = "#{full_path}/#{file}"
          if File.directory?(file_path)
            scan_folder("#{folder}/#{file}")
          else
            filename = file_path[(file_path.rindex('/')+1)..-1]
            @assets << Asset.new do |a|
              a.name = AssetLoader.name_from_filename(filename)
              if folder.include? '/'
                a.path = folder[(folder.index('/') + 1)..-1]
              else
                a.path = ''
              end
              a.type = AssetLoader.type_from_filename(filename)
              a.content = File.read(file_path)
            end
          end
        end
      end
    end
  end
end