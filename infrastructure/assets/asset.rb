module MusicOne
  module Assets
    class Asset
      attr_accessor :name, :type, :content
      def initialize
        yield self if block_given?
      end
    end
  end
end