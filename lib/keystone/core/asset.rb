require 'digest/md5'

module Keystone
  class Asset
    attr_accessor :name, :path, :type, :type_history, :content, :location_on_disk
    def initialize
      @path = ''
      @type_history = []
      yield self if block_given?
    end

    def type=(val)
      @type = val
      @type_history << val unless @type_history.include?(val)
    end

    def current_hash
      @location_on_disk.nil? ? Digest::MD5.hexdigest(@content) : Digest::MD5.hexdigest(File.read(@location_on_disk))
    end
  end
end