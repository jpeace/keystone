describe Keystone::AssetTools::Sassy do
  _simple_sassy = %{
    $variable: 10px;
    .style {
      text-size: $variable;
    }
  }

  _simple_css = 
%{.style {
  text-size: 10px; }
}
  
  _sassy_module = %{
    $var1: 10px;
    $var2: #fff;
    @mixin blue-text {
      color: blue;
    }
  }

  _sassy_with_import = %{
    @import 'path/module';

    .style {
      @include blue-text;
      font-size: $var1;
      background-color: $var2;
    }
  }

  _complex_css = 
%{.style {
  color: blue;
  font-size: 10px;
  background-color: white; }
}

  _simple = Keystone::Asset.new do |a|
    a.name = 'simple'
    a.type = Keystone::Types::Sassy
    a.path = 'path/to/file'
    a.location_on_disk = '/home/test/path/to/file'
    a.content = _simple_sassy
  end

  _unknown = Keystone::Asset.new do |a|
    a.name = 'unknown'
    a.type = Keystone::Types::Unknown
    a.content = "Shouldn't change"
  end

  _module = Keystone::Asset.new do |a|
    a.name = '_module'
    a.type = Keystone::Types::Sassy
    a.path = 'path'
    a.content = _sassy_module
  end

  _with_import = Keystone::Asset.new do |a|
    a.name = 'complex'
    a.type = Keystone::Types::Sassy
    a.content = _sassy_with_import
  end

  it "doesn't include non-sassy assets" do
    subject.run([_unknown]).first.content.should eq "Shouldn't change"
  end

  it "changes the type to css" do
    subject.run([_simple]).first.type.should eq Keystone::Types::Css
  end

  it "compiles the sassy css to regular css" do
    subject.run([_simple]).first.content.should eq _simple_css
  end

  it "works with import statements" do
    transformed = subject.run([_module, _with_import])
    transformed.should have_exactly(1).items
    transformed.first.content.should eq _complex_css
  end

  it "preserves the path" do
    subject.run([_simple]).first.path.should eq 'path/to/file'
  end

  it "preserves the location on disk" do
    subject.run([_simple]).first.location_on_disk.should eq '/home/test/path/to/file'
  end
  
end