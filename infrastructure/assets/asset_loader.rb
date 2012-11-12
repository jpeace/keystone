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

      def initialize
        @assets = []
      end

      def scan!(path)
        scan_path(path)
      end

      private

      def scan_path(path)
        Dir.foreach(path) do |file|
          next if ['.', '..'].include?(file)

          full_path = "#{path}/#{file}"
          if File.directory?(full_path)
            scan_path(full_path)
          else
            last_slash = full_path.rindex('/')
            path = full_path[0,last_slash]
            filename = full_path[last_slash, -1]
            puts path
            puts filename
          end
        end
      end
    end
  end
end