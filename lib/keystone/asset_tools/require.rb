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
    var transformed_path = path.replace(/\//g, '__')
    var factory = modules[tranformed_path];
    if (factory === null) {
      return null;
    } else {
      return modules[tranformed_path]();
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
        %{
(function() {
  var modules = window.modules || [];
  var #{asset.name}Cache = null;
  var #{asset.name}Func = function() {
    #{asset.content}
  };
  modules.#{asset.path.gsub(/\//, '__')}__#{asset.name} = function() {
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