module Keystone
  class AssetPipeline
    attr_reader :compilers

    def initialize(compilers)
      @compilers = compilers
    end

    def compiler(name)
      @compilers.find {|c| c.package_name == name}
    end
  end
end