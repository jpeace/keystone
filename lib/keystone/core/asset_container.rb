require 'digest/md5'

module Keystone
  module AssetContainer
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
      parsed = /^((?:\w+\/)*)(\w+)(\.(\w+))?$/.match(path_and_name)
      path = parsed[1].gsub(/\/$/,'')
      name = parsed[2]
      extension = parsed[4]

      results = @assets.select{ |a| a.path == path && a.name == name }
      if extension.nil?
        return results.first
      else
        return results.find{ |a| a.type == Keystone::AssetLoader.type_from_extension(extension)}
      end
    end
  end
end