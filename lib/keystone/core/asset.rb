require 'digest/md5'

module Keystone
  class Asset
    attr_accessor :name, :path, :type, :content, :location_on_disk
    def initialize
      @path = ''
      yield self if block_given?
    end

    def current_hash
      @location_on_disk.nil ? Digest::MD5.hexdigest(@content) : Digest::MD5.hexdigest(File.read(@location_on_disk))
    end
  end
end