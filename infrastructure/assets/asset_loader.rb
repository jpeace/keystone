module MusicOne
  module Assets
    class AssetLoader
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
      end
    end
  end
end