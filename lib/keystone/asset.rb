module Keystone
  class Asset
    attr_accessor :name, :path, :type, :content
    def initialize
      yield self if block_given?
    end
  end
end