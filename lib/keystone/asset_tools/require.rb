module Keystone
  module AssetTools
    class Require
      include Keystone::AssetTool

      alias original_run run
      def run(assets)
        transformed = original_run(assets)
        transformed << Keystone::Asset.new do |a|
          a.name = 'require'
          a.type = Keystone::Types::Javascript
          a.content = %{
(function() {
  var modules = window.modules || [];
  window.require = function(path) {
    var transformedPath = path.replace(/\\//g, '__');
    if (transformedPath.indexOf('__') === -1) {
      transformedPath = '__' + transformedPath;
    }
    var factory = modules[transformedPath];
    if (factory === null) {
      return null;
    } else {
      return modules[transformedPath]();
    }
  };
})();}
        end

        return transformed
      end

      def should_run?(asset)
        asset.type == Keystone::Types::Javascript
      end

      def transform(asset)
        if asset.type_history.include?(Keystone::Types::Coffeescript)
          asset.content.sub!(/^(\s+)?/, '\1return ')
        end
        %{
(function() {
  var modules = window.modules || [];
  var #{asset.name}Cache = null;
  var #{asset.name}Func = function() {
    #{asset.content}
  };
  modules.#{asset.namespace.gsub(/\//, '__')}__#{asset.name} = function() {
    if (#{asset.name}Cache === null) {
      #{asset.name}Cache = #{asset.name}Func();
    }
    return #{asset.name}Cache;
  };
  window.modules = modules;
})();}
      end
    end
  end
end