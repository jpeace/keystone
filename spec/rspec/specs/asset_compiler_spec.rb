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

class ReplaceCaps
  include MusicOne::AssetTool
  def should_run?
    true
  end
  def transform
    @original.content.gsub(/[A-Z]/, '-')
  end
end
replace_caps = ReplaceCaps.new

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

class ShortenString
  include MusicOne::AssetTool
  def should_run?
    true
  end
  def transform
    @original.content[1,100]
  end
end

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
asset3 = MusicOne::Asset.new do |a|
          a.name = "asset3"
          a.type = :boring
          a.content = "Not quick enough"
        end

describe "classes mixing in the AssetTool module" do
  it "return an asset when run" do
    replace_qs.run(asset1).should be_is_a(MusicOne::Asset)
  end
    
  context "when defining should_run?" do
    it "can return false to be skipped" do
      double_string.run(asset1).content.should eq 'How Quick is Shaq?'
    end
  end

  context "when defining transform" do
    it "can return a string to transform contents" do
      replace_qs.run(asset1).content.should eq 'How *uick is Sha*?'
    end

    it "can return an array to transform type and contents" do
      asset = double_string.run(asset2)
      asset.type.should eq :doubled
      asset.content.should eq 'QQuuiittee  ddoouubblleedd'
    end
  end
end

describe MusicOne::AssetCompiler do
  context "with a single element toolchain" do
    subject do
      toolchain = [ReplaceQs]
      described_class.new(toolchain, [asset1, asset2])
    end

    it "compiles assets" do
      subject.compile!
      subject['asset1'].content.should eq 'How *uick is Sha*?'
      subject['asset2'].content.should eq '*uite doubled'
    end
  end

  context "with a multiple element toolchain" do
    subject do
      toolchain = [ReplaceCaps, ReplaceQs]
      described_class.new(toolchain, [asset1, asset2])
    end

    it "compiles assets" do
      subject.compile!
      subject['asset1'].content.should eq '-ow -uick is -ha*?'
      subject['asset2'].content.should eq '-uite doubled'
    end
  end

  it "runs the toolchain using the order given" do
    c1 = described_class.new([ReplaceQs, ReplaceCaps], [asset1])
    c2 = described_class.new([ReplaceCaps, ReplaceQs], [asset1])
    
    c1.compile! && c2.compile!
    
    c1['asset1'].content.should eq '-ow *uick is -ha*?'
    c2['asset1'].content.should eq '-ow -uick is -ha*?'
  end

  it "only compiles once" do
    c = described_class.new([ShortenString], [asset2])
    c.compile!
    c.compile!
    c['asset2'].content.should eq 'uite doubled'
  end

  context "when building a package" do
    it "chooses the type of the first asset when determining package type" do
      c = described_class.new([], [asset1, asset3])
      c.package_type.should eq :boring

      c = described_class.new([], [asset2, asset3])
      c.package_type.should eq :too_short
    end

    it "uses the package name given" do
      c = described_class.new([],[],:package_name => 'new_package')
      c.package_name.should eq 'new_package'
    end

    it "uses the package type for package name if no name given" do
      c = described_class.new([],[asset1])
      c.package_name.should eq 'boring'
    end

    it "builds an asset package" do
      c = described_class.new([ReplaceCaps, ShortenString], [asset1, asset2])
      package = c.build!

      package.name.should eq 'boring'
      package.type.should eq :boring
      package.content.should eq "ow -uick is -haq?\nuite doubled"
    end

    it "uses post-build steps if specified" do
      c = described_class.new([ReplaceCaps], [asset1, asset3], :post_build => [ReplaceQs])
      package = c.build!

      package.type.should eq :boring
      package.content.should eq "-ow -uick is -ha*?\n-ot *uick enough"
    end
  end
end