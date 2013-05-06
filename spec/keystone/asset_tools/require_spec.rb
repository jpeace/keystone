describe Keystone::AssetTools::Require do
  _javascript = %{
    var x = 5;
    var f = function(y) {
      alert(x+y);
    };
}
  
  _tranformed_coffeescript = %{
    (function() {
      var x = 5;
      var f = function(y) {
        alert(x+y);
      };
    })();
}

  _wrapped = %{
(function() {
  var modules = window.modules || [];
  var libCache = null;
  var libFunc = function() {
    
    var x = 5;
    var f = function(y) {
      alert(x+y);
    };

  };
  modules.path__to__lib__lib = function() {
    if (libCache === null) {
      libCache = libFunc();
    }
    return libCache;
  };
  window.modules = modules;
})();}
  
  _wrapped_coffeescript = %{
(function() {
  var modules = window.modules || [];
  var libCache = null;
  var libFunc = function() {
    
    return (function() {
      var x = 5;
      var f = function(y) {
        alert(x+y);
      };
    })();

  };
  modules.path__to__lib__lib = function() {
    if (libCache === null) {
      libCache = libFunc();
    }
    return libCache;
  };
  window.modules = modules;
})();}


  _require_def = %{
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

  _asset = Keystone::Asset.new do |a|
    a.name = 'lib'
    a.namespace = 'path/to/lib'
    a.type = Keystone::Types::Javascript
    a.content = _javascript
  end

  _coffeescript_asset = Keystone::Asset.new do |a|
    a.name = 'lib'
    a.namespace = 'path/to/lib'
    a.type = Keystone::Types::Javascript
    a.type_history = [Keystone::Types::Coffeescript, Keystone::Types::Javascript]
    a.content = _tranformed_coffeescript
  end

  _unknown = Keystone::Asset.new do |a|
    a.name = 'unknown'
    a.type = Keystone::Types::Unknown
    a.content = "Shouldn't change"
  end

  it "doesn't tranform non-javascript assets" do
    subject.run([_unknown]).first.content.should eq "Shouldn't change"
  end

  it "wraps javascript code into require modules" do
    subject.run([_asset]).first.content.should eq _wrapped
  end

  it "adds a return statement if the javascript has been tranformed from coffeescript" do
    subject.run([_coffeescript_asset]).first.content.should eq _wrapped_coffeescript
  end

  it "adds an asset for the require definition" do
    transformed = subject.run([_asset])
    transformed.should have_exactly(2).items

    require_def = transformed.find {|a| a.name == 'require'}
    require_def.content.should eq _require_def
  end
end