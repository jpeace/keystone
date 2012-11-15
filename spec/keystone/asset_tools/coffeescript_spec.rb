describe Keystone::AssetTools::Coffeescript do
  _coffeescript = %{
    class C
      method: ->
        @a = [1,2,3,4,5]
    c = new C()
  }

  _javascript = 
%{(function() {
  var C, c;

  C = (function() {

    function C() {}

    C.prototype.method = function() {
      return this.a = [1, 2, 3, 4, 5];
    };

    return C;

  })();

  c = new C();

}).call(this);
}

  _asset = Keystone::Asset.new do |a|
    a.type = Keystone::Types::Coffeescript
    a.content = _coffeescript
  end

  it "changes the type to javascript" do
    subject.run(_asset).type.should eq Keystone::Types::Javascript
  end

  it "compiles the coffeescript to javascript" do
    subject.run(_asset).content.should eq _javascript
  end
end