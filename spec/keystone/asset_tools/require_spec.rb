describe Keystone::AssetTools::Require do
  _javascript = %{
    var x = 5;
    var f = function(y) {
      alert(x+y);
    };
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

  _require_def = %{
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

  _asset = Keystone::Asset.new do |a|
    a.name = 'lib'
    a.path = 'path/to/lib'
    a.type = Keystone::Types::Javascript
    a.content = _javascript
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

  it "adds an asset for the require definition" do
    transformed = subject.run([_asset])
    transformed.should have_exactly(2).items

    require_def = transformed.find {|a| a.name == 'require'}
    require_def.content.should eq _require_def
  end
end