describe MusicOne::Assets::AssetLoader do
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