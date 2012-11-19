describe Keystone::AssetTools::Closure do
  _original = %{
    var Class = function() {
      this.saySomething = function(param) {
        alert(param);
      };
    };
    var Object = new Class();
  }

  _transformed = 
%{var Class=function(){this.saySomething=function(a){alert(a)}},Object=new Class;
}

  _asset = Keystone::Asset.new do |a|
    a.type = Keystone::Types::Javascript
    a.content = _original
  end

  _coffeescript = Keystone::Asset.new do |a|
    a.type = Keystone::Types::Coffeescript
    a.content = "shouldn't change"
  end

  it "only tranforms javascript files" do
    subject.run([_coffeescript]).first.content.should eq "shouldn't change"
  end

  it "minifies javascript files" do
    subject.run([_asset]).first.content.should eq _transformed
  end
end