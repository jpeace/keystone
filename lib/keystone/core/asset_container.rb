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
      path = ''
      name = path_and_name
      slash = path_and_name.rindex('/')
      unless slash.nil?
        path = path_and_name[0,slash]
        name = path_and_name[slash+1..-1]
      end

      return @assets.find{ |a| a.path == path && a.name == name }
    end
  end
end