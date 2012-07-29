describe MusicOne::AssetLoader do
  _cut = described_class

  context "when determining content type from files" do
    it "recognizes coffeescript files" do
      _cut.type_from_filename('script.coffee').should eq :coffee
    end
    it "recognizes javascript files" do
      _cut.type_from_filename('script.js').should eq :javascript
    end
    it "recognizes sassy css files" do
      _cut.type_from_filename('styles.scss').should eq :sassy
    end
    it "recognizes css files" do
      _cut.type_from_filename('styles.css').should eq :css
    end
    it "defaults to unknown" do
      _cut.type_from_filename('settings.cfg').should eq :unknown
    end
    it "works with no extension" do
      _cut.type_from_filename('license').should eq :unknown
    end
    it "works with dots in the filename" do
      _cut.type_from_filename('lib.min.js').should eq :javascript
    end
  end
end

class ReplaceQs
  include MusicOne::AssetTool
  def should_run?
    true
  end
  def transform
    @original.content.gsub(/[qQ]/, '*')
  end
end
replace_qs = ReplaceQs.new

class DoubleString
  include MusicOne::AssetTool
  def should_run?
    @original.type == :too_short
  end
  def transform
    doubled = ''
    @original.content.each_char {|c| doubled << "#{c}#{c}"}
    [:doubled, doubled]
  end
end
double_string = DoubleString.new

asset1 = MusicOne::Asset.new do |a|
          a.name = "asset1"
          a.type = :boring
          a.content = "How Quick is Shaq?"
        end
asset2 = MusicOne::Asset.new do |a|
          a.name = "asset2"
          a.type = :too_short
          a.content = "Quite doubled"
        end
assets = [asset1,asset2]

describe "classes mixing in the AssetTool module" do
  it "return an asset when run" do
    replace_qs.run!(asset1).should be_is_a(MusicOne::Asset)
  end
    
  context "when defining should_run?" do
    it "can return false to be skipped" do
      double_string.run!(asset1).content.should eq 'How Quick is Shaq?'
    end
  end

  context "when defining transform" do
    it "can return a string to transform contents" do
      replace_qs.run!(asset1).content.should eq 'How *uick is Sha*?'
    end

    it "can return an array to transform type and contents" do
      asset = double_string.run!(asset2)
      asset.type.should eq :doubled
      asset.content.should eq 'QQuuiittee  ddoouubblleedd'
    end
  end
end

describe MusicOne::AssetCompiler do
  subject do
    toolchain = [ReplaceQs]
    described_class.new(toolchain, assets)
  end

  it "compiles assets" do
    subject.compile
  end
end